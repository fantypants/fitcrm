defmodule FitcrmWeb.WeekdayController do
  use FitcrmWeb, :controller
  use Timex
  alias Fitcrm.Plan.Weekday
  import Plug.Conn
  import Ecto.Query
  import Phoenix.Controller
  import FitcrmWeb.Router.Helpers
  import FitcrmWeb.Authorize
  alias Fitcrm.Foods.Meal
  alias Fitcrm.Foods.Food
  alias Phauxth.Log
  alias Fitcrm.Accounts
  alias Fitcrm.Tools
  alias Fitcrm.Plan.Excercise
  alias Fitcrm.Accounts.User
  alias Fitcrm.Tools.ClientTool
  alias Fitcrm.Tools.Parent
  alias Fitcrm.Plan.Week

  plug :user_check when action in [:index, :show]
  #plug :id_check when action in [:update, :delete]

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    user = user.id
    IO.puts "Weekindex"
    weekdays = Fitcrm.Repo.all(Weekday)
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "index.html", weekdays: weekdays, user: user, changeset: changeset)
  end

  def new(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    changeset = Weekday.changeset(%Weekday{})
    users = [user.user_id]
    render(conn, "new.html", changeset: changeset, users: users)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"weekday" => weekday_params}) do
    user_id = user.user_id
    user_tdee = user.tdee
    level = Fitcrm.Repo.get!(User, user_id).planlevel
    type = Fitcrm.Repo.get!(User, user_id).plantype
    workout_id = Tools.ClientTool.getWorkoutID(level,type)
    selected_workouts = Tools.ClientTool.selectWorkout(workout_id, weekday_params["day"])
    meal_ids = Tools.ClientTool.getMealID(user_tdee)
    selected_meals = Tools.ClientTool.selectMeals(meal_ids.breakfast, meal_ids.lunch, meal_ids.dinner)
    intermediate_params = weekday_params |> Map.merge(selected_meals)
    new_params = intermediate_params |> Map.merge(selected_workouts)
    changeset = Weekday.changeset(%Weekday{}, new_params)
    case Fitcrm.Repo.insert(changeset) do
      {:ok, weekday} ->
        conn
        |> put_flash(:info, "Weekday created successfully.")
        |> redirect(to: weekday_path(conn, :show, weekday))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def showweek(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user_id" => user_id, "week_id" => week_id}) do
    query = from w in Weekday, where: w.week_id == ^week_id
    Fitcrm.Repo.all(Week) |> IO.inspect
    week = Fitcrm.Repo.get!(Week, week_id)
    weekdays = Fitcrm.Repo.all(query)
    changeset = Accounts.change_user(%Accounts.User{})
    user = (user_id == to_string(user.id) and user) || Accounts.get(user_id)
    conn |> render("weeks.html", week: week, weekdays: weekdays, user: user, changeset: changeset)
  end

  def weekindex(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user_id" => user_id}) do
    weeks = Fitcrm.Repo.all(from w in Week, where: w.user_id == ^user_id)
    changeset = Accounts.change_user(%Accounts.User{})
    conn |> render("weekindex.html", weeks: weeks, user: user, changeset: changeset)
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    #
    Fitcrm.Repo.all(from w in Weekday, where: w.week_id == ^2) |> IO.inspect
    users = [user.id]
    s = user.id
    changeset = Accounts.change_user(%Accounts.User{})
    weekday = Fitcrm.Repo.get!(Weekday, id)
    bid= Map.fetch!(weekday, :breakfast)
    lid= Map.fetch!(weekday, :lunch)
    did= Map.fetch!(weekday, :dinner)
    mealids = [bid, lid, did]
    meals = mealids |> Enum.map(fn(a) -> %{
      name: Fitcrm.Repo.get!(Meal, a).name,
      fat: Fitcrm.Repo.get!(Meal, a).fat,
      carbs: Fitcrm.Repo.get!(Meal, a).carbs,
      prot: Fitcrm.Repo.get!(Meal, a).protein,
      cal: Fitcrm.Repo.get!(Meal, a).calories,
      type: Fitcrm.Repo.get!(Meal, a).type,
      id: a,
      recipe: "Just chuck the ingredients in the microwave mate",
      foodids: Fitcrm.Repo.get!(Meal,a).foodid
      } end)
    mealsfull = meals |> Enum.map(fn(a) -> %{id: a.id, name: a.name, fat: a.fat, prot: a.prot, carbs: a.carbs, cals: a.cal, type: a.type, recipe: a.recipe, foodids: getfullmeal(a.foodids)} end) |> IO.inspect
    excercises = weekday.excercises |> Enum.map(fn(a) -> %{
      name: Fitcrm.Repo.get!(Excercise, a).name,
      reps: Fitcrm.Repo.get!(Excercise, a).reps}
    end)
    render(conn, "show.html", weekday: weekday, excercises: excercises, mealsfull: mealsfull, users: users, s: s, user: user, changeset: changeset)
  end

  def returnMeals(id) do
    weekday = Fitcrm.Repo.get!(Weekday, id)
    bid= Map.fetch!(weekday, :breakfast)
    lid= Map.fetch!(weekday, :lunch)
    did= Map.fetch!(weekday, :dinner)
    [bid, lid, did]
  end

  def returnDay(id) do
    weekday = Fitcrm.Repo.get!(Weekday, id)
    bid= Map.fetch!(weekday, :breakfast)
    lid= Map.fetch!(weekday, :lunch)
    did= Map.fetch!(weekday, :dinner)
    mealids = [bid, lid, did]
    meals = mealids |> Enum.map(fn(a) -> %{
      name: Fitcrm.Repo.get!(Meal, a).name,
      type: Fitcrm.Repo.get!(Meal, a).type,
      id: a,
      recipe: "Just chuck the ingredients in the microwave mate",
      foodids: Fitcrm.Repo.get!(Meal,a).foodid
      } end)
    mealsfull = meals |> Enum.map(fn(a) -> %{id: a.id, name: a.name, type: a.type, recipe: a.recipe, foodids: getfullmeal(a.foodids)} end) |> IO.inspect
    excercises = weekday.excercises |> Enum.map(fn(a) -> %{
      name: Fitcrm.Repo.get!(Excercise, a).name,
      reps: Fitcrm.Repo.get!(Excercise, a).reps}
    end)

    %{weekday: weekday.day, excercises: excercises, mealsfull: mealsfull}
  end

  def getfullmeal(foodids) do
    foods = foodids |> Enum.map(fn(a) -> %{
      name: Fitcrm.Repo.get!(Food, a).name,
      p: Fitcrm.Repo.get!(Food, a).protein,
      c: Fitcrm.Repo.get!(Food, a).carbs,
      f: Fitcrm.Repo.get!(Food, a).fat,
      cal: Fitcrm.Repo.get!(Food, a).calories,
      q: Fitcrm.Repo.get!(Food, a).quantity}
    end)
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id, "user_id" => user_id}) do
    #user = (user_id == to_string(user.id) and user) || Accounts.get(user_id)
    meals = get_meallist(conn)
    IO.puts "Breakfast choices"
    breakfast = meals.breakfast |> Enum.map(fn(a) -> Fitcrm.Repo.get!(Meal, a) end) |> Enum.take_random(3)
    lunch = meals.lunch |> Enum.map(fn(a) -> Fitcrm.Repo.get!(Meal, a) end) |> Enum.take_random(3)
    dinner = meals.dinner |> Enum.map(fn(a) -> Fitcrm.Repo.get!(Meal, a) end) |> Enum.take_random(3)
    weekday = Fitcrm.Repo.get!(Weekday, id)
    changeset = Weekday.changeset(weekday)
    render(conn, "edit.html", weekday: weekday, changeset: changeset, user: user, meals: meals, breakfast: breakfast, lunch: lunch, dinner: dinner)
  end

  def update(conn, %{"id" => id, "weekday" => weekday_params}) do
    IO.puts "Weekday Params are: "
    IO.inspect weekday_params
    weekday = Fitcrm.Repo.get!(Weekday, id)
    changeset = Weekday.changeset(weekday, weekday_params)

    case Fitcrm.Repo.update(changeset) do
      {:ok, weekday} ->
        conn
        |> put_flash(:info, "Weekday updated successfully.")
        |> redirect(to: weekday_path(conn, :show, weekday))
      {:error, changeset} ->
        render(conn, "edit.html", weekday: weekday, changeset: changeset)
    end
  end

  def create_day(id, day) do
      IO.puts "Day is: #{day}"
      veg = Fitcrm.Repo.get!(User, id).veg
      pcos = Fitcrm.Repo.get!(User, id).pcos
      user_tdee = Fitcrm.Repo.get!(User, id).tdee
      level = Fitcrm.Repo.get!(User, id).planlevel
      type = Fitcrm.Repo.get!(User, id).plantype
      weekday_params = %{"day" => day}
      workout_id = Tools.ClientTool.getWorkoutID(level,type)
      selected_workouts = Tools.ClientTool.selectWorkout(workout_id, day)
      meal_ids = Tools.ClientTool.getMealID(user_tdee, veg, pcos)
      selected_meals = Tools.ClientTool.selectMeals(meal_ids.breakfast, meal_ids.lunch, meal_ids.dinner)
      int_params = weekday_params |> Map.merge(selected_meals)
      int_params |> Map.merge(selected_workouts)
  end

  def get_and_update(user_id, day_id, day) do
    weekday = Fitcrm.Repo.get!(Weekday, day_id)
    IO.puts "Day is:"
    user_tdee = Fitcrm.Repo.get!(User, user_id).tdee
    weekday_params = %{"day" => day, "id" => day_id}
    level = Fitcrm.Repo.get!(User, user_id).planlevel
    type = Fitcrm.Repo.get!(User, user_id).plantype
    workout_id = Tools.ClientTool.getWorkoutID(level,type)
    selected_workouts = Tools.ClientTool.selectWorkout(workout_id, day)
    meal_ids = Tools.ClientTool.getMealID(user_tdee)
    selected_meals = Tools.ClientTool.selectMeals(meal_ids.breakfast, meal_ids.lunch, meal_ids.dinner)
    int_params = weekday_params |> Map.merge(selected_meals)
    new_params = int_params |> Map.merge(selected_workouts)
    changeset = Weekday.changeset(weekday, new_params)
    case Fitcrm.Repo.update(changeset) do
      {:ok, weekday} ->
        IO.puts "Succesfully Updated"
        IO.inspect weekday
        IO.inspect changeset
      {:error, changeset} ->
        IO.puts "Error Occured updatign changeset"
    end
  end

  def get_meallist(%Plug.Conn{assigns: %{current_user: user}} = conn) do
    user_tdee = user.tdee
    user_veg = user.veg
    user_pcos = user.pcos
    meal_ids = Tools.ClientTool.getMealID(user_tdee, user_veg, user_pcos) |> IO.inspect
  end

  def createWeekMap(user_id) do
    day_params = Tools.ClientTool.getDate()
    day_params |> Enum.map(fn(a) -> create_day(user_id, elem(a, 1)) end)
  end

  def check_exists(%Plug.Conn{assigns: %{current_user: user}} = conn) do
    IO.puts "Week exists?"
    query = from w in Week, where: w.user_id ==^user.id
    weeks = Fitcrm.Repo.all(query) |> IO.inspect
    case weeks do
      [] ->
        IO.puts "No Week Exists"
        create_week(conn)
      _->
      IO.puts "Week Exists"
        ClientTool.getUserDates(user.id)
    end
  end

  def create_week(%Plug.Conn{assigns: %{current_user: user}} = conn) do
    user_id = user.id
    day_params = createWeekMap(user_id)

    end_date = Timex.local |> Date.add(7) |> IO.inspect
    params = %{
      "user_id" => user_id,
      "start" => Timex.local,
      "end" => Timex.to_naive_datetime(end_date),
      "weekdays" => day_params
    }
    changeset= Week.changeset(%Week{}, params)
    case Fitcrm.Repo.insert(changeset) do
      {:ok, week} ->
        IO.puts "Succesfully Inserted New Week"
        IO.inspect week
        IO.inspect changeset
      {:error, changeset} ->
        IO.puts "Error Occured updatign changeset"
        IO.inspect changeset
    end

  end

  def getDay(day) do
    case day do
      "Monday" ->
        "Tuesday"
      "Tuesday" ->
        "Wednesday"
      "Wednesday" ->
        "Thursday"
      "Thursday" ->
        "Friday"
      "Friday" ->
        "Saturday"
      "Saturday" ->
        "Sunday"
      "Sunday" ->
        "Monday"
      end
  end

  def update_week(id) do
    week = Fitcrm.Repo.get!(Week, id) |> Fitcrm.Repo.preload(:weekdays)
    u_id = Map.fetch!(week, :user_id)
    case u_id do
      nil ->
        user_id = 1
      _->
      user_id = u_id
    end
    day_params = createWeekMap(user_id) |> Enum.map(fn(a) -> a["day"] end)
    week.weekdays |> Enum.map(fn(a) -> get_and_update(user_id, a.id, getDay(a.day)) end)
    end_date = Timex.local |> Date.add(7)
    params = %{
      "start" => Timex.local,
      "end" => Timex.to_naive_datetime(end_date)
    }
    changeset= Week.changeset(week, params)
    case Fitcrm.Repo.update(changeset) do
      {:ok, week} ->
        IO.puts "Succesfully Updated"
        IO.inspect week
        IO.inspect changeset

      {:error, changeset} ->
        IO.puts "Error Occured While Updating the Week changeset"
        IO.inspect changeset
    end

  end

  def jsonweek(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    user = Fitcrm.Repo.get!(User, user.id)
    query = from w in Week, where: w.user_id == ^ user.id, select: w.id
    week_id = Fitcrm.Repo.all(query)
    weekday_query = from w in Weekday, where: w.week_id == ^List.first(week_id)
    days_full = Fitcrm.Repo.all(weekday_query)
    days = days_full |> Enum.map(fn(a) -> %{
      day: returnDay(a.id)
      } end)


    case week_id do
      [] ->
        week_resp = {:error, "No Weeks Generated"}
      _->
        week_resp = {:ok, List.first(week_id)}
    end
    IO.inspect week_resp

    case week_resp do
      {:error, message} ->
        week = %{id: "Error", days: "None"}
      {:ok, week_id} ->
        week = %{id: week_id, days: days}
    end

    conn |> render("week.json", %{week: week})

  end

  def delete(conn, %{"id" => id}) do
    weekday = Repo.get!(Weekday, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(weekday)

    conn
    |> put_flash(:info, "Weekday deleted successfully.")
    |> redirect(to: weekday_path(conn, :index))
  end
end

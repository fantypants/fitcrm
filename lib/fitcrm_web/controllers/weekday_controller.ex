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
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _params) do
    weekdays = Fitcrm.Repo.all(Weekday)
    render(conn, "index.html", weekdays: weekdays)
  end

  def new(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    changeset = Weekday.changeset(%Weekday{})
    users = [user.id]
    render(conn, "new.html", changeset: changeset, users: users)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"weekday" => weekday_params}) do
    user_id = user.id
    user_tdee = user.tdee
    workout_id = Tools.ClientTool.getWorkoutID("Beginner","Shred")
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

  def showweek(conn, %{"id" => id}) do
    query = from w in Weekday, where: w.week_id == ^1
    week = Fitcrm.Repo.get!(Week, 1)
    weekdays = Fitcrm.Repo.all(query)

    conn |> render("weeks.html", week: week, weekdays: weekdays)
  end

  def show(conn, %{"id" => id}) do
    Tools.ClientTool.getDate()
    Tools.ClientTool.queryTargetDates(conn)
    #createWeekMap(conn) |> IO.inspect
    #create_week(conn)

    Fitcrm.Repo.all(from w in Weekday, where: w.week_id == ^2) |> IO.inspect

    weekday = Fitcrm.Repo.get!(Weekday, id)
    bid= Map.fetch!(weekday, :breakfast)
    lid= Map.fetch!(weekday, :lunch)
    did= Map.fetch!(weekday, :dinner)
    mealids = [bid, lid, did]
    meals = mealids |> Enum.map(fn(a) -> %{
      name: Fitcrm.Repo.get!(Meal, a).name,
      type: "mealtype test",
      recipe: "Just chuck the ingredients in the microwave mate",
      foodids: Fitcrm.Repo.get!(Meal,a).foodid
      } end)
    mealsfull = meals |> Enum.map(fn(a) -> %{name: a.name, type: a.type, recipe: a.recipe, foodids: getfullmeal(a.foodids)} end) |> IO.inspect

    excercises = weekday.excercises |> Enum.map(fn(a) -> %{
      name: Fitcrm.Repo.get!(Excercise, a).name,
      reps: Fitcrm.Repo.get!(Excercise, a).reps}
    end)
    render(conn, "show.html", weekday: weekday, excercises: excercises, mealsfull: mealsfull)
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

  def edit(conn, %{"id" => id}) do
    weekday = Repo.get!(Weekday, id)
    changeset = Weekday.changeset(weekday)
    render(conn, "edit.html", weekday: weekday, changeset: changeset)
  end

  def update(conn, %{"id" => id, "weekday" => weekday_params}) do
    weekday = Repo.get!(Weekday, id)
    changeset = Weekday.changeset(weekday, weekday_params)

    case Repo.update(changeset) do
      {:ok, weekday} ->
        conn
        |> put_flash(:info, "Weekday updated successfully.")
        |> redirect(to: weekday_path(conn, :show, weekday))
      {:error, changeset} ->
        render(conn, "edit.html", weekday: weekday, changeset: changeset)
    end
  end

  def create_day(%Plug.Conn{assigns: %{current_user: user}} = conn, day) do
      IO.puts "Day is: #{day}"
      user_id = user.id
      user_tdee = user.tdee
      weekday_params = %{"day" => day}
      workout_id = Tools.ClientTool.getWorkoutID("Beginner","Shred")
      selected_workouts = Tools.ClientTool.selectWorkout(workout_id, day)
      meal_ids = Tools.ClientTool.getMealID(user_tdee)
      selected_meals = Tools.ClientTool.selectMeals(meal_ids.breakfast, meal_ids.lunch, meal_ids.dinner)
      int_params = weekday_params |> Map.merge(selected_meals)
      int_params |> Map.merge(selected_workouts)
  end

  def get_and_update(%Plug.Conn{assigns: %{current_user: user}} = conn, day_id) do
    weekday = Fitcrm.Repo.get!(Weekday, day_id)
    IO.puts "Day is:"
    day = Tools.ClientTool.getCurrentDay |> IO.inspect
    user_id = user.id
    user_tdee = user.tdee
    weekday_params = %{"day" => day, "id" => day_id}
    workout_id = Tools.ClientTool.getWorkoutID("Beginner","Shred")
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

  def createWeekMap(conn) do
    day_params = Tools.ClientTool.getDate()
    day_params |> Enum.map(fn(a) -> create_day(conn, elem(a, 1)) end)
  end

  def create_week(%Plug.Conn{assigns: %{current_user: user}} = conn) do
    day_params = createWeekMap(conn)
    params = %{
      "start" => Timex.local,
      "end" => Timex.local,
      "weekdays" => day_params
    }
    changeset= Week.changeset(%Week{}, params)
    case Fitcrm.Repo.insert(changeset) do
      {:ok, week} ->
        IO.puts "Succesfully Updated"
        IO.inspect week
        IO.inspect changeset
      {:error, changeset} ->
        IO.puts "Error Occured updatign changeset"
        IO.inspect changeset
    end

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

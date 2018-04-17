defmodule FitcrmWeb.WeekdayController do
  use FitcrmWeb, :controller

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

  def show(conn, %{"id" => id}) do
    weekday = Fitcrm.Repo.get!(Weekday, id) |> IO.inspect
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

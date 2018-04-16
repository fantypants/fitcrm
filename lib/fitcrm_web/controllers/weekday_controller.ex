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
    IO.puts "Old params"
    IO.inspect weekday_params
    user_id = user.id
    user_tdee = user.tdee


    workout_id = Tools.ClientTool.getWorkoutID("Beginner","Shred")
    selected_workouts = Tools.ClientTool.selectWorkout(workout_id, "1") |> IO.inspect
    meal_ids = Tools.ClientTool.getMealID(user_tdee)
    selected_meals = Tools.ClientTool.selectMeals(meal_ids.breakfast, meal_ids.lunch, meal_ids.dinner)
    # Retrieve Workouts applicable
    # Get the corresponding ID and insert into DB
    #weekday_params |> Map.put(:breakfast, selected_meals.b)
    #weekday_params |> Map.put(:lunch, selected_meals.l)
    #weekday_params |> Map.put(:dinner, selected_meals.d)
    IO.puts "new params"
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
    meals = %{
      b: Fitcrm.Repo.get!(Meal,bid).name,
      l: Fitcrm.Repo.get!(Meal,lid).name,
      d: Fitcrm.Repo.get!(Meal,did).name
    }
    excercises = weekday.excercises |> Enum.map(fn(a) -> %{
      name: Fitcrm.Repo.get!(Excercise, a).name,
      reps: Fitcrm.Repo.get!(Excercise, a).reps}
    end)
    render(conn, "show.html", weekday: weekday, excercises: excercises, meals: meals)
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

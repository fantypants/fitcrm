defmodule FitcrmWeb.WorkoutController do
  use FitcrmWeb, :controller
  alias Fitcrm.Plan.Workout
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
  alias Fitcrm.Accounts.User
  alias Fitcrm.Tools.ClientTool
  alias Fitcrm.Plan.Excercise

  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, _params) do
    workouts = Fitcrm.Repo.all(Workout)
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "index.html", workouts: workouts, changeset: changeset)
  end

  def new(conn, _params) do
    changeset = Workout.changeset(%Workout{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"workout" => workout_params}) do
    IO.inspect workout_params
    if upload = workout_params["file"] do
       excercise_params = Tools.Io.csvimport_workout(workout_params)
    end
    notes = workout_params["notes"]
    name = workout_params["name"]
    type = workout_params["type"]
    level = workout_params["level"]
    workouts = %{notes: notes, name: name}
    excercises = [%{
      day: "Monday",
      name: "This",
      reps: "that"}]
    new_workout_params = %{
      "excercises" => excercise_params,
      "name" => name,
      "notes" => notes,
      "type" => type,
      "level" => level
    }
    IO.inspect new_workout_params
    changeset = Workout.changeset(%Workout{}, new_workout_params)
    case Fitcrm.Repo.insert(changeset) do
      {:ok, workout} ->
        conn
        |> put_flash(:info, "Workout created successfully.")
        |> redirect(to: workout_path(conn, :show, workout))
      {:error, changeset} ->
        IO.inspect changeset
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    workout = Fitcrm.Repo.get!(Workout, id) #|> Fitcrm.Repo.preload(:excercises) |> IO.inspect
    excercises = Fitcrm.Repo.all(from e in Excercise, where: e.workout_id == ^id)
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "show.html", workout: workout, excercises: excercises, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    workout = Fitcrm.Repo.get!(Workout, id)
    changeset = Workout.changeset(workout)
    render(conn, "edit.html", workout: workout, changeset: changeset)
  end

  def update(conn, %{"id" => id, "workout" => workout_params}) do
    workout = Fitcrm.Repo.get!(Workout, id)
    changeset = Workout.changeset(workout, workout_params)

    case Fitcrm.Repo.update(changeset) do
      {:ok, workout} ->
        conn
        |> put_flash(:info, "Workout updated successfully.")
        |> redirect(to: workout_path(conn, :show, workout))
      {:error, changeset} ->
        render(conn, "edit.html", workout: workout, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    workout = Fitcrm.Repo.get!(Workout, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Fitcrm.Repo.delete!(workout)

    conn
    |> put_flash(:info, "Workout deleted successfully.")
    |> redirect(to: workout_path(conn, :index))
  end
end

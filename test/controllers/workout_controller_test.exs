defmodule Fitcrm.WorkoutControllerTest do
  use Fitcrm.ConnCase

  alias Fitcrm.Workout
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, workout_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing workouts"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, workout_path(conn, :new)
    assert html_response(conn, 200) =~ "New workout"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, workout_path(conn, :create), workout: @valid_attrs
    workout = Repo.get_by!(Workout, @valid_attrs)
    assert redirected_to(conn) == workout_path(conn, :show, workout.id)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, workout_path(conn, :create), workout: @invalid_attrs
    assert html_response(conn, 200) =~ "New workout"
  end

  test "shows chosen resource", %{conn: conn} do
    workout = Repo.insert! %Workout{}
    conn = get conn, workout_path(conn, :show, workout)
    assert html_response(conn, 200) =~ "Show workout"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, workout_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    workout = Repo.insert! %Workout{}
    conn = get conn, workout_path(conn, :edit, workout)
    assert html_response(conn, 200) =~ "Edit workout"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    workout = Repo.insert! %Workout{}
    conn = put conn, workout_path(conn, :update, workout), workout: @valid_attrs
    assert redirected_to(conn) == workout_path(conn, :show, workout)
    assert Repo.get_by(Workout, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    workout = Repo.insert! %Workout{}
    conn = put conn, workout_path(conn, :update, workout), workout: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit workout"
  end

  test "deletes chosen resource", %{conn: conn} do
    workout = Repo.insert! %Workout{}
    conn = delete conn, workout_path(conn, :delete, workout)
    assert redirected_to(conn) == workout_path(conn, :index)
    refute Repo.get(Workout, workout.id)
  end
end

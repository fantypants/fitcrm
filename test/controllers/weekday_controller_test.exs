defmodule Fitcrm.WeekdayControllerTest do
  use Fitcrm.ConnCase

  alias Fitcrm.Weekday
  @valid_attrs %{breakfast: 42, dinner: 42, excercise: 42, lunch: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, weekday_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing weekdays"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, weekday_path(conn, :new)
    assert html_response(conn, 200) =~ "New weekday"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, weekday_path(conn, :create), weekday: @valid_attrs
    weekday = Repo.get_by!(Weekday, @valid_attrs)
    assert redirected_to(conn) == weekday_path(conn, :show, weekday.id)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, weekday_path(conn, :create), weekday: @invalid_attrs
    assert html_response(conn, 200) =~ "New weekday"
  end

  test "shows chosen resource", %{conn: conn} do
    weekday = Repo.insert! %Weekday{}
    conn = get conn, weekday_path(conn, :show, weekday)
    assert html_response(conn, 200) =~ "Show weekday"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, weekday_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    weekday = Repo.insert! %Weekday{}
    conn = get conn, weekday_path(conn, :edit, weekday)
    assert html_response(conn, 200) =~ "Edit weekday"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    weekday = Repo.insert! %Weekday{}
    conn = put conn, weekday_path(conn, :update, weekday), weekday: @valid_attrs
    assert redirected_to(conn) == weekday_path(conn, :show, weekday)
    assert Repo.get_by(Weekday, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    weekday = Repo.insert! %Weekday{}
    conn = put conn, weekday_path(conn, :update, weekday), weekday: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit weekday"
  end

  test "deletes chosen resource", %{conn: conn} do
    weekday = Repo.insert! %Weekday{}
    conn = delete conn, weekday_path(conn, :delete, weekday)
    assert redirected_to(conn) == weekday_path(conn, :index)
    refute Repo.get(Weekday, weekday.id)
  end
end

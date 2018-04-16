defmodule Fitcrm.WeekdayTest do
  use Fitcrm.ModelCase

  alias Fitcrm.Weekday

  @valid_attrs %{breakfast: 42, dinner: 42, excercise: 42, lunch: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Weekday.changeset(%Weekday{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Weekday.changeset(%Weekday{}, @invalid_attrs)
    refute changeset.valid?
  end
end

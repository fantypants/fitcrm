defmodule Fitcrm.DayTest do
  use Fitcrm.ModelCase

  alias Fitcrm.Day

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Day.changeset(%Day{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Day.changeset(%Day{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule Fitcrm.WorkoutTest do
  use Fitcrm.ModelCase

  alias Fitcrm.Workout

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Workout.changeset(%Workout{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Workout.changeset(%Workout{}, @invalid_attrs)
    refute changeset.valid?
  end
end

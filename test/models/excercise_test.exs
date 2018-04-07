defmodule Fitcrm.ExcerciseTest do
  use Fitcrm.ModelCase

  alias Fitcrm.Excercise

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Excercise.changeset(%Excercise{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Excercise.changeset(%Excercise{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule Fitcrm.FoodidTest do
  use Fitcrm.ModelCase

  alias Fitcrm.Foodid

  @valid_attrs %{f_id: "some f_id"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Foodid.changeset(%Foodid{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Foodid.changeset(%Foodid{}, @invalid_attrs)
    refute changeset.valid?
  end
end

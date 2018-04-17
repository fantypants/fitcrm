defmodule Fitcrm.WeekTest do
  use Fitcrm.ModelCase

  alias Fitcrm.Week

  @valid_attrs %{end: ~N[2010-04-17 14:00:00.000000], start: ~N[2010-04-17 14:00:00.000000]}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Week.changeset(%Week{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Week.changeset(%Week{}, @invalid_attrs)
    refute changeset.valid?
  end
end

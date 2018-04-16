defmodule Fitcrm.Plan.Weekday do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Plan.Weekday

  schema "weekdays" do
    field :breakfast, :integer
    field :lunch, :integer
    field :dinner, :integer
    field :excercises, {:array, :integer}

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:breakfast, :lunch, :dinner, :excercises])
    |> validate_required([:breakfast, :lunch, :dinner, :excercises])
  end
end

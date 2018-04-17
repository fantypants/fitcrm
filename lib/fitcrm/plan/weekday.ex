defmodule Fitcrm.Plan.Weekday do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Plan.Weekday

  schema "weekdays" do
    field :breakfast, :integer
    field :day, :string
    field :lunch, :integer
    field :dinner, :integer
    field :excercises, {:array, :integer}

    belongs_to :week, Fitcrm.Plan.Week
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:breakfast, :lunch, :dinner, :excercises, :day, :week_id])
    |> validate_required([:breakfast, :lunch, :dinner, :excercises, :day])
  end
end

defmodule Fitcrm.Plan.Day do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Plan.Day

  schema "days" do
    field :dayofweek, :string

    belongs_to :excercises, Fitcrm.Plan.Excercise
    has_many :meals, Fitcrm.Plan.Meal
    has_many :workouts, Fitcrm.Plan.Workout
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:dayofweek, :excercise_id])
    |> cast_assoc(:meals)
    |> cast_assoc(:workouts)
    |> validate_required([:dayofweek, :excercise_id])
  end
end

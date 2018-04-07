defmodule Fitcrm.Plan.Day do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Plan.Day

  schema "days" do
    field :dayofweek, :string

    belongs_to :workouts, Fitcrm.Plan.Workout
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:dayofweek, :workout_id])
    |> validate_required([:dayofweek, :workout_id])
  end
end

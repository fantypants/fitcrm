defmodule Fitcrm.Plan.Excercise do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Plan.Excercise

  schema "excercises" do
    field :name, :string
    field :reps, :string

    belongs_to :workouts, Fitcrm.Plan.Workout
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :reps, :workout_id])
    |> validate_required([:name, :reps, :workout_id])
  end
end

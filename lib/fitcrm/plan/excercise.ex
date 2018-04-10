defmodule Fitcrm.Plan.Excercise do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Plan.Excercise

  schema "excercises" do
    field :name, :string
    field :reps, :string
    field :day, :string


    belongs_to :workout, Fitcrm.Plan.Workout
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :reps, :day, :workout_id])
    |> validate_required([:name, :reps, :day])
  end
end

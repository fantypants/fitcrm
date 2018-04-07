defmodule Fitcrm.Plan.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workouts" do
      field :name, :string
      field :notes, :string

      has_many :days, Fitcrm.Plan.Day
      has_many :excercises, Fitcrm.Plan.Excercise
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :notes])
    |> cast_assoc(:days)
    |> cast_assoc(:excercises)
    |> validate_required([])
  end
end

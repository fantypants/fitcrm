defmodule Fitcrm.Plan.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  schema "workouts" do
      field :name, :string
      field :notes, :string
      field :type, :string
      field :level, :string


      has_many :excercises, Fitcrm.Plan.Excercise
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :notes, :type, :level])
    |> cast_assoc(:excercises)
    |> validate_required([:name, :notes, :type, :level])
  end
end

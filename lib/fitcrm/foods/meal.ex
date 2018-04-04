defmodule Fitcrm.Foods.Meal do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Foods.Meal


  schema "meals" do
    field :name, :string
    field :calories, :float
    field :fat, :float
    field :carbs, :float
    field :protein, :float

    has_many :foods, Fitcrm.Foods.Food

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :calories, :fat, :carbs, :protein])
    |> cast_assoc(:foods)
    |> validate_required([:name, :calories, :fat, :carbs, :protein])
  end
end

defmodule Fitcrm.Foods.Food do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Foods.Food

  schema "foods" do
    field :name, :string
    field :protein, :float
    field :fat, :float
    field :carbs, :float
    field :calories, :float
    field :quantity, :string
    field :meal_ident, {:array, :integer}


    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :quantity, :protein, :fat, :carbs, :calories, :meal_ident])
    |> validate_required([:name, :quantity, :protein, :fat, :carbs, :calories, :meal_ident])
  end
end

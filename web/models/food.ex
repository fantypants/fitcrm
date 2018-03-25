defmodule Fitcrm.Food do
  use Fitcrm.Web, :model

  schema "foods" do
    field :name, :string
    field :protein, :float
    field :fat, :float
    field :carbs, :float
    field :calories, :float

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :protein, :fat, :carbs, :calories])
    |> validate_required([:name, :protein, :fat, :carbs, :calories])
  end
end

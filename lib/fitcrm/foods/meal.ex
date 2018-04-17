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
    field :foodid, {:array, :integer}
    field :recipe, :string
    field :type, :string

    belongs_to :day, Fitcrm.Plan.Day
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :foodid, :calories, :fat, :carbs, :protein, :day_id, :recipe, :type])
    |> validate_required([:name, :foodid, :calories, :fat, :carbs, :protein, :type, :recipe])
  end
end

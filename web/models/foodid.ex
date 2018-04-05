defmodule Fitcrm.Foodid do
  use Fitcrm.Web, :model

  schema "foodids" do
    field :f_id, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:f_id])
    |> validate_required([:f_id])
  end
end

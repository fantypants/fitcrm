defmodule Fitcrm.Plan.Week do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Plan.Week

  schema "weeks" do
    field :start, :naive_datetime
    field :end, :naive_datetime

    has_many :weekdays, Fitcrm.Plan.Weekday
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start, :end])
    |> cast_assoc(:weekdays)
    |> validate_required([:start, :end])
  end
end

defmodule Fitcrm.Plan.Week do
  use Ecto.Schema
  import Ecto.Changeset
  alias Fitcrm.Plan.Week

  schema "weeks" do
    field :start, :naive_datetime
    field :end, :naive_datetime

    has_many :weekdays, Fitcrm.Plan.Weekday
    belongs_to :user, Fitcrm.Accounts.User
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start, :end, :user_id])
    |> cast_assoc(:weekdays)
    |> validate_required([:start, :end, :user_id])
  end
end

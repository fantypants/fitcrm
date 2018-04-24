defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding referral id" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :ref_id, {:array, :integer}
    end
  end
end

defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding pcos and ir to user table" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :pcos, :boolean
      add :ir, :boolean
    end
  end
end

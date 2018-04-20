defmodule :"Elixir.Fitcrm.Repo.Migrations.Eddit user" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :plantype, :string
      add :planlevel, :string
    end
  end
end

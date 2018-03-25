defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding User Types" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :type, :string
      add :name, :string
    end
  end
end

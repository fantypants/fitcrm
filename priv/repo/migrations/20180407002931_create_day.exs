defmodule Fitcrm.Repo.Migrations.CreateDay do
  use Ecto.Migration

  def change do
    create table(:days) do
        add :dayofweek, :string
      timestamps()
    end
  end
end

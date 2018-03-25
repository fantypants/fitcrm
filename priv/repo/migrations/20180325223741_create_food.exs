defmodule Fitcrm.Repo.Migrations.CreateFood do
  use Ecto.Migration

  def change do
    create table(:foods) do
      add :name, :string
      add :protein, :float
      add :fat, :float
      add :carbs, :float
      add :calories, :float

      timestamps()
    end
  end
end

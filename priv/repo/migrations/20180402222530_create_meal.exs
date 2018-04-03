defmodule Fitcrm.Repo.Migrations.CreateMeal do
  use Ecto.Migration

  def change do
    create table(:meals) do
      add :name, :string
      add :calories, :float
      add :fat, :float
      add :carbs, :float
      add :protein, :float

      timestamps()
    end
  end
end

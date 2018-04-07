defmodule Fitcrm.Repo.Migrations.CreateExcercise do
  use Ecto.Migration

  def change do
    create table(:excercises) do
      add :name, :string
      add :reps, :string
      timestamps()
    end
  end
end

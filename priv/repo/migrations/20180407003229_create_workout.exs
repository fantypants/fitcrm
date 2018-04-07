defmodule Fitcrm.Repo.Migrations.CreateWorkout do
  use Ecto.Migration

  def change do
    create table(:workouts) do
        add :name, :string
        add :notes, :string
      timestamps()
    end
  end
end

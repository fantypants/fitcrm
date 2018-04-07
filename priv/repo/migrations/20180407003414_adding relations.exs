defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding relations" do
  use Ecto.Migration

  def change do
    alter table(:days) do
      add :workout_id, references(:workouts)
    end
    alter table(:excercises) do
      add :workout_id, references(:workouts)
    end
  end
end

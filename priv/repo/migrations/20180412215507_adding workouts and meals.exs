defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding workouts and meals" do
  use Ecto.Migration

  def change do
    alter table(:workouts) do
      add :day_id, references(:days, on_delete: :delete_all)
    end
    alter table(:meals) do
      add :day_id, references(:days, on_delete: :delete_all)
    end
  end
end

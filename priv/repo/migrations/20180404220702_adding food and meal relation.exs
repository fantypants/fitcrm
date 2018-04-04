defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding food and meal relation" do
  use Ecto.Migration

  def change do
    alter table(:foods) do
      add :meal_id, references(:meals)
    end
  end
end

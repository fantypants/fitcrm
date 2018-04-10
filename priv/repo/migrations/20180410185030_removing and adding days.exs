defmodule :"Elixir.Fitcrm.Repo.Migrations.Removing and adding days" do
  use Ecto.Migration

  def change do
    alter table(:days) do
      remove :workout_id
      add :day, :string

    end
  end
end

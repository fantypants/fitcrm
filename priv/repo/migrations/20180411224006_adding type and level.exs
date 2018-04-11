defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding type and level" do
  use Ecto.Migration

  def change do
    alter table(:workouts) do
      add :type, :string
      add :level, :string

    end
  end
end

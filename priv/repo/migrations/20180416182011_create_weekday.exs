defmodule Fitcrm.Repo.Migrations.CreateWeekday do
  use Ecto.Migration

  def change do
    create table(:weekdays) do
      add :breakfast, :integer
      add :lunch, :integer
      add :dinner, :integer
      add :excercise, :integer

      timestamps()
    end
  end
end

defmodule Fitcrm.Repo.Migrations.CreateWeek do
  use Ecto.Migration

  def change do
    create table(:weeks) do
      add :start, :naive_datetime
      add :end, :naive_datetime


      timestamps()
    end
  end
end

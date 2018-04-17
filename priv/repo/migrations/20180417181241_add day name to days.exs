defmodule :"Elixir.Fitcrm.Repo.Migrations.Add day name to days" do
  use Ecto.Migration

  def change do
    alter table(:weekdays) do
      add :day, :string
    end
  end
end

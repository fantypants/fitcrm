defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding day to week" do
  use Ecto.Migration

  def change do
    alter table(:weekdays) do
      add :week_id, references(:weeks, on_delete: :delete_all)
    end
  end
end

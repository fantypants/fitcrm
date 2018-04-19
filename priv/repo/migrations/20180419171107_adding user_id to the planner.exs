defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding userId to the planner" do
  use Ecto.Migration

  def change do
    alter table(:weeks) do
        add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end

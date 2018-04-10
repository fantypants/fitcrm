defmodule :"Elixir.Fitcrm.Repo.Migrations.Removing and adding days" do
  use Ecto.Migration

  def change do
    alter table(:excercises) do
      add :day, :string
    end
  end
end

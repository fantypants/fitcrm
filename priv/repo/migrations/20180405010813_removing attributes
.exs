defmodule :"Elixir.Fitcrm.Repo.Migrations.Removing attributes\n" do
  use Ecto.Migration

  def change do
    alter table(:foods) do
      remove :meal_id
      add :meal, :integer
    end    
  end
end

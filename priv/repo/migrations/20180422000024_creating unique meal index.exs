defmodule :"Elixir.Fitcrm.Repo.Migrations.Creating unique meal index" do
  use Ecto.Migration

  def change do

      create unique_index(:meals, [:name])
    
  end
end

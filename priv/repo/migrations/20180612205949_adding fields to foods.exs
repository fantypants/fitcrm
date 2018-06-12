defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding fields to foods" do
  use Ecto.Migration

  def change do
    alter table(:meals) do
      add :pcos, :boolean
      add :veg, :boolean
  end
end
end

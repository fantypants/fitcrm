defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding fields to user" do
  use Ecto.Migration

  def change do
    alter table (:users) do
      add :veg, :boolean
    end
  end
end

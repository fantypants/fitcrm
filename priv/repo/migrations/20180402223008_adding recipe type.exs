defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding recipe type" do
  use Ecto.Migration

  def change do
    alter table(:meals) do
      add :recipe, :string
      add :type, :string

    end
  end
end

defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding meal id" do
  use Ecto.Migration

  def change do
    alter table(:foods) do
      add :meal_ident, {:array, :integer}
    end
  end
end

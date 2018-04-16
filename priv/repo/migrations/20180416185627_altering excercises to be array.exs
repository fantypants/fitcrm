defmodule :"Elixir.Fitcrm.Repo.Migrations.Altering excercises to be array" do
  use Ecto.Migration

  def change do
    alter table(:weekdays) do

      remove :excercise
      add :excercises, {:array, :integer}


    end
  end
end

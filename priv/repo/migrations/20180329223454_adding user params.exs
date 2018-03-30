defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding user params" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :sex, :string
      add :height, :float
      add :weight, :float
      add :age, :integer
      add :activity, :integer
      add :bmr, :float
      add :tdee, :float
    end
  end
end

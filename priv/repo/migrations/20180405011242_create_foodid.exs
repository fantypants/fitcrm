defmodule Fitcrm.Repo.Migrations.CreateFoodid do
  use Ecto.Migration

  def change do
    create table(:foodids) do
      add :f_id, :string
      timestamps()
    end
    alter table(:meals) do
      add :foodid, {:array, :integer}
    end
  end
end

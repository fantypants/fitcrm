defmodule :"Elixir.Fitcrm.Repo.Migrations.Adding attributes to meals" do
  use Ecto.Migration

  def change do
    alter table(:foods) do
      add :quantity, :string

    end
  end
end

defmodule :"Elixir.Fitcrm.Repo.Migrations.PCOS AND IR TEXT UPDATE" do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :pcos
      remove :ir
      add :ir, :string
      add :pcos, :string
    end
  end
end

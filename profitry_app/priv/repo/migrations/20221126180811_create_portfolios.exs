defmodule ProfitryApp.Repo.Migrations.CreatePortfolios do
  use Ecto.Migration

  def change do
    create table(:portfolios) do
      add :tikr, :string
      add :name, :string

      timestamps()
    end
  end
end

defmodule Profitry.Server.Repo.Migrations.CreatePortfolios do
  use Ecto.Migration

  def change do
    create table(:portfolios) do
      add :name, :string
      add :description, :string

      timestamps()
    end

  end
end

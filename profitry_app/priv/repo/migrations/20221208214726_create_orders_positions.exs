defmodule ProfitryApp.Repo.Migrations.CreateOrdersPositions do
  use Ecto.Migration

  def change do
    alter table(:portfolios) do
      modify :ticker, :citext, null: false
    end

    create table(:positions) do
      add :ticker, :citext, null: false
      add :portfolio_id, references(:portfolios, on_delete: :nothing)

      timestamps()
    end

    create index(:positions, [:portfolio_id])

    create table(:orders) do
      add :type, :citext, null: false
      add :instrument, :citext, null: false
      add :quantity, :decimal
      add :price, :decimal
      add :position_id, references(:positions, on_delete: :nothing)

      timestamps()
    end

    create index(:orders, [:position_id])
  end
end

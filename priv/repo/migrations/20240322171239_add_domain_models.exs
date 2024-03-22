defmodule Profitry.Repo.Migrations.AddDomainModels do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext"

    create table(:portfolios) do
      add :broker, :citext, null: false
      add :description, :string

      timestamps()
    end

    create table(:positions) do
      add :ticker, :citext, null: false
      add :portfolio_id, references(:portfolios, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:positions, [:ticker, :portfolio_id],
             name: :positions_ticker_portfolio_index
           )

    create table(:orders) do
      add :type, :citext, null: false
      add :instrument, :citext, null: false
      add :quantity, :decimal
      add :price, :decimal
      add :position_id, references(:positions, on_delete: :nothing)

      timestamps()
    end

    create index(:orders, [:position_id])

    create table(:options) do
      add :strike, :integer
      add :order_id, references(:orders, on_delete: :nothing)

      timestamps()
    end

    create index(:options, [:order_id])
  end
end

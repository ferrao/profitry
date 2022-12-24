defmodule ProfitryApp.Repo.Migrations.ConstraintPositions do
  use Ecto.Migration

  def change do
    create unique_index(:positions, [:ticker, :portfolio_id],
             name: :positions_ticker_portfolio_index
           )
  end
end

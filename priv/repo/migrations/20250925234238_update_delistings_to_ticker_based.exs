defmodule Profitry.Repo.Migrations.UpdateDelistingsToTickerBased do
  use Ecto.Migration

  def change do
    # First, we need to handle existing data - drop the table and recreate with new structure
    # Since this is early development and there's likely no production data, this is acceptable
    drop table(:delistings)

    # Create the table with the new ticker-based structure
    create table(:delistings) do
      add :date, :date, null: false
      add :payout, :decimal, null: false, default: "0.00"
      add :ticker, :citext, null: false

      timestamps()
    end

    create unique_index(:delistings, [:ticker])
  end
end

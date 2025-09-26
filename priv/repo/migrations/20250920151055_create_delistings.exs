defmodule Profitry.Repo.Migrations.CreateDelistings do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:delistings) do
      add :date, :date, null: false
      add :payout, :decimal, null: false, default: "0.00"
      add :ticker, :citext, null: false

      timestamps()
    end

    create unique_index(:delistings, [:ticker])
  end
end

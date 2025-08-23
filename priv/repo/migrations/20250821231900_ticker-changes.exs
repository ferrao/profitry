defmodule :"Elixir.Profitry.Repo.Migrations.Ticker-changes" do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:ticker_changes) do
      add :ticker, :citext, null: false
      add :original_ticker, :citext, null: false
      add :date, :date, null: false

      timestamps()
    end

    create unique_index(:ticker_changes, [:ticker, :date],
             name: :ticker_date_ticker_changes_index
           )
  end
end

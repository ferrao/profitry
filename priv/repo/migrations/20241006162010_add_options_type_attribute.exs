defmodule Profitry.Repo.Migrations.AddOptionsTypeAttribute do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext"

    alter table(:options) do
      add :type, :citext, null: false
    end
  end
end

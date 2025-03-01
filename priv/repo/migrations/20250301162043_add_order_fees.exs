defmodule Profitry.Repo.Migrations.AddOrderFees do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :fees, :decimal, default: 0
    end
  end
end

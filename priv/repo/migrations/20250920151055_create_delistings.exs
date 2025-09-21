defmodule Profitry.Repo.Migrations.CreateDelistings do
  use Ecto.Migration

  def change do
    create table(:delistings) do
      add :delisted_on, :date, null: false
      add :payout, :decimal, null: false, default: "0.00"
      add :position_id, references(:positions, on_delete: :delete_all), null: true

      timestamps()
    end

    create unique_index(:delistings, [:position_id])
  end
end

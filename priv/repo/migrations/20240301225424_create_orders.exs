defmodule Profitry.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do

      timestamps()
    end
  end
end

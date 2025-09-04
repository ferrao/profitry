defmodule Profitry.Repo.Migrations.DecimalMultiple do
  use Ecto.Migration

  def change do
    alter table(:splits) do
      modify :multiple, :decimal, null: false
    end
  end
end

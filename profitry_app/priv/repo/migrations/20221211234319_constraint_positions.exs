defmodule ProfitryApp.Repo.Migrations.ConstraintPositions do
  use Ecto.Migration

  def change do
    create unique_index(:positions, [:ticker])
  end
end

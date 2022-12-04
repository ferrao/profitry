defmodule ProfitryApp.Repo.Migrations.RelatePortfoliosUsers do
  use Ecto.Migration

  def change do
    alter table(:portfolios) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:portfolios, [:user_id])
  end
end

defmodule ProfitryApp.Core.Portfolio do
  use Ecto.Schema
  import Ecto.Changeset

  schema "portfolios" do
    field :name, :string
    field :tikr, :string

    timestamps()
  end

  @doc false
  def changeset(portfolio, attrs) do
    portfolio
    |> cast(attrs, [:tikr, :name])
    |> validate_required([:tikr, :name])
  end
end

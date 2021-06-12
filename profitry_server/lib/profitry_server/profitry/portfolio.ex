defmodule Profitry.Server.Profitry.Portfolio do
  use Ecto.Schema
  import Ecto.Changeset

  schema "portfolios" do
    field :description, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(portfolio, attrs) do
    portfolio
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end

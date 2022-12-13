defmodule ProfitryApp.Investment.Position do
  use Ecto.Schema

  import Ecto.Changeset
  alias ProfitryApp.Investment.{Order, Portfolio}

  schema "positions" do
    field :ticker, :string
    has_many :orders, Order

    belongs_to :portfolio, Portfolio
  end

  def changeset(position, attrs) do
    position
    |> cast(attrs, [:ticker])
    |> validate_required([:ticker])
    |> unique_constraint(:ticker)
    |> no_assoc_constraint(:orders, message: "Position contains orders")
  end
end

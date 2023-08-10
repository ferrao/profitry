defmodule ProfitryApp.Investment.Position do
  @moduledoc """

  Schema representing a portfolio position

  """
  use Ecto.Schema

  import Ecto.Changeset
  import ProfitryApp.Utils.Ecto

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
    |> capitalize(:ticker)
    |> unique_constraint([:ticker, :portfolio])
    |> no_assoc_constraint(:orders, message: "Position contains orders")
  end
end

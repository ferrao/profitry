defmodule Profitry.Investment.Position do
  @moduledoc """

    Schema representing a portfolio position

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  alias Profitry.Investment.{Order, Portfolio}

  @type t :: %__MODULE__{
          ticker: String.t(),
          orders: list(Order.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "positions" do
    field :ticker, :string
    has_many :orders, Order
    belongs_to :portfolio, Portfolio

    timestamps()
  end

  def changeset(position, attrs) do
    position
    |> cast(attrs, [:ticker])
    |> validate_required([:ticker])
    |> capitalize([:ticker])
    |> unique_constraint([:ticker])
    |> no_assoc_constraint(:orders, message: "Position contains orders")
  end
end

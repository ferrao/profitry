defmodule Profitry.Investment.Schema.Position do
  @moduledoc """

  Schema representing a portfolio position

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  alias Profitry.Investment.Schema.{Order, Portfolio}

  @type t :: %__MODULE__{
          ticker: String.t(),
          orders: list(Order.t()),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
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
    |> capitalize(:ticker)
    |> unique_constraint([:ticker, :portfolio])
    |> no_assoc_constraint(:orders, message: "Position contains orders")
  end
end

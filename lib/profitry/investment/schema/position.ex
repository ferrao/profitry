defmodule Profitry.Investment.Schema.Position do
  @moduledoc """

  Ecto schema representing a portfolio position

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  alias Profitry.Investment.Schema.{Order, Portfolio}

  @type t :: %__MODULE__{
          ticker: String.t() | nil,
          orders: list(Order.t()) | Ecto.Association.NotLoaded.t() | nil,
          portfolio: Portfolio.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "positions" do
    field :ticker, :string
    has_many :orders, Order
    belongs_to :portfolio, Portfolio

    timestamps()
  end

  @doc """

  Creates an Ecto Changeset for the Position schema

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(position, attrs) do
    position
    |> cast(attrs, [:ticker])
    |> validate_required([:ticker])
    |> capitalize(:ticker)
    |> unique_constraint([:ticker, :portfolio])
    |> no_assoc_constraint(:orders, message: "Position contains orders")
  end
end

defmodule Profitry.Investment.Schema.Option do
  @moduledoc """

  Ecto schema representing the details of an options contract for an order to buy/sell premium

  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Profitry.Investment.Schema.Order

  @type contract_type :: :call | :put
  @type t :: %__MODULE__{
          strike: Decimal.t(),
          expiration: Date.t(),
          type: contract_type,
          order: Order.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "options" do
    field :type, Ecto.Enum, values: [:call, :put]
    field :strike, :decimal
    field :expiration, :date
    belongs_to :order, Order

    timestamps()
  end

  @shares_per_contract 100

  @doc """

  The number of shares per option contract

  """
  @spec shares_per_contract() :: integer()
  def shares_per_contract, do: @shares_per_contract

  @doc """

  The value of the option contract

  """
  @spec option_value(Decimal.t()) :: Decimal.t()
  def option_value(price), do: Decimal.mult(@shares_per_contract, price)

  def changeset(option, attrs) do
    option
    |> cast(attrs, [:type, :strike, :expiration])
    |> validate_required([:type, :strike, :expiration])
    |> validate_number(:strike, greater_than: 0)
  end
end

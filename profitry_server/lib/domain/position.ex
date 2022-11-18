defmodule Profitry.Domain.Position do
  alias Profitry.Domain.{Position, StockOrder, OptionsOrder}

  @type t :: %__MODULE__{
          ticker: String.t(),
          orders: list(StockOrder.t() | OptionsOrder.t())
        }

  defstruct(
    ticker: nil,
    orders: []
  )

  # Creates a new position on an underlying using stocks
  @spec new_position(String.t(), StockOrder.t()) :: Position.t()
  def new_position(ticker, order = %StockOrder{quantity: quantity, price: price})
      when quantity > 0 and
             price >= 0 do
    %Position{
      ticker: ticker,
      orders: [%{order | quantity: to_string(order.quantity), price: to_string(order.price)}]
    }
  end

  # Creates a new position on an underlying using stock options
  @spec new_position(String.t(), OptionsOrder.t()) :: Position.t()
  def new_position(ticker, order = %OptionsOrder{contracts: contracts, premium: premium})
      when contracts > 0 and premium > 0 do
    %Position{
      ticker: ticker,
      orders: [%{order | contracts: to_string(contracts), premium: to_string(premium)}]
    }
  end

  # Adds a new stocks order to an existing position
  @spec make_order(Position.t(), StockOrder.t()) :: Position.t()
  def make_order(position, order = %StockOrder{quantity: quantity, price: price})
      when quantity > 0 and price >= 0 do
    Map.put(position, :orders, [
      %{order | quantity: to_string(quantity), price: to_string(price)} | position.orders
    ])
  end

  # Adds a new stock options order to an existing position
  @spec make_order(Position.t(), OptionsOrder.t()) :: Position.t()
  def make_order(position, order = %OptionsOrder{contracts: contracts, premium: premium})
      when premium > 0 do
    Map.put(position, :orders, [
      %{order | contracts: to_string(contracts), premium: to_string(premium)} | position.orders
    ])
  end
end

defmodule Profitry.Position do
  alias Profitry.Position

  defstruct(
    ticker: nil,
    orders: []
  )

  alias Profitry.{StockOrder, OptionsOrder}

  # Creates a new position on an underlying using stocks
  def new_position(ticker, order = %StockOrder{quantity: quantity, price: price})
      when quantity > 0 and
             price >= 0 do
    %Position{
      ticker: ticker,
      orders: [%{order | quantity: to_string(order.quantity), price: to_string(order.price)}]
    }
  end

  # Creates a new position on an underlying using stock options
  def new_position(ticker, order = %OptionsOrder{premium: premium})
      when premium > 0 do
    %Position{
      ticker: ticker,
      orders: [%{order | premium: to_string(premium)}]
    }
  end

  # Adds a new stocks order to an existing position
  def make_order(position, order = %StockOrder{quantity: quantity, price: price})
      when quantity > 0 and price >= 0 do
    Map.put(position, :orders, [
      %{order | quantity: to_string(quantity), price: to_string(price)} | position.orders
    ])
  end

  # Adds a new stock options order to an existing position
  def make_order(position, order = %OptionsOrder{premium: premium})
      when premium > 0 do
    Map.put(position, :orders, [%{order | premium: to_string(premium)} | position.orders])
  end
end

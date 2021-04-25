defmodule Profitry.Position do
  defstruct(
    ticker: nil,
    orders: []
  )

  def new_position(ticker, order = %{quantity: quantity, price: price})
      when quantity > 0 and
             price >= 0 do
    %Profitry.Position{
      ticker: ticker,
      orders: [%{order | quantity: to_string(order.quantity), price: to_string(order.price)}]
    }
  end

  def new_position(ticker, order = %{premium: premium})
      when premium > 0 do
    %Profitry.Position{
      ticker: ticker,
      orders: [%{order | premium: to_string(premium)}]
    }
  end

  def make_order(position, order = %{quantity: quantity, price: price})
      when quantity > 0 and price >= 0 do
    Map.put(position, :orders, [
      %{order | quantity: to_string(quantity), price: to_string(price)} | position.orders
    ])
  end

  def make_order(position, order = %{premium: premium})
      when premium > 0 do
    Map.put(position, :orders, [%{order | premium: to_string(premium)} | position.orders])
  end
end

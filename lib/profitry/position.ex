defmodule Profitry.Position do
  defstruct(
    ticker: "",
    orders: []
  )

  def new_position(ticker, order = %{type: :buy, quantity: quantity, price: price})
      when quantity > 0 and
             price >= 0 do
    %Profitry.Position{
      ticker: ticker,
      orders: [order]
    }
  end

  def make_order(position, order = %{quantity: quantity, price: price})
      when quantity > 0 and price >= 0 do
    Map.put(position, :orders, [order | position.orders])
  end
end

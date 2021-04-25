defmodule Profitry.StockOrder do
  # stock orders are either buy or sell
  defstruct(
    type: :buy,
    quantity: 0,
    price: 0
  )
end

defmodule Profitry.Core.StockOrder do
  # stock orders are either a buy or a sell
  defstruct(
    type: :buy,
    quantity: 0,
    price: 0
  )
end

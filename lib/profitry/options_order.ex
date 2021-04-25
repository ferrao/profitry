defmodule Profitry.OptionsOrder do
  # stock options orders are either a buy or a sell
  defstruct(
    type: :buy,
    premium: 0
  )
end

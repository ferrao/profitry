defmodule Profitry.StockOrder do
  @type t :: %__MODULE__{
          type: Profitry.order(),
          quantity: integer(),
          price: Decimal.t()
        }

  defstruct(
    type: :buy,
    quantity: 0,
    price: 0
  )
end

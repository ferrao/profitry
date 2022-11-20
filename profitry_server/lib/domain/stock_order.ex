defmodule Profitry.Domain.StockOrder do
  @type t :: %__MODULE__{
          type: Profitry.order(),
          quantity: Decimal.t(),
          price: Decimal.t(),
          ts: integer()
        }

  defstruct(
    type: :buy,
    quantity: 0,
    price: 0,
    ts: 0
  )
end

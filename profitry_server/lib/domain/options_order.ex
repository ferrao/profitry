defmodule Profitry.Domain.OptionsOrder do
  @type t :: %__MODULE__{
          type: Profitry.order(),
          contracts: integer(),
          premium: Decimal.t(),
          ts: integer()
        }

  defstruct(
    type: :buy,
    contracts: 0,
    premium: 0,
    ts: 0
  )
end

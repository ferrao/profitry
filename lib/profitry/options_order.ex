defmodule Profitry.OptionsOrder do
  @type t :: %__MODULE__{
          type: Profitry.Portfolio.order(),
          premium: Decimal.t()
        }

  defstruct(
    type: :buy,
    premium: 0
  )
end

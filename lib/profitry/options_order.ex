defmodule Profitry.OptionsOrder do
  @type t :: %__MODULE__{
          type: Profitry.order(),
          premium: Decimal.t()
        }

  defstruct(
    type: :buy,
    premium: 0
  )
end

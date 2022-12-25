defmodule ProfitryApp.Exchanges.Quote do
  @type t :: %__MODULE__{
          ticker: String.t(),
          price: Decimal.t(),
          ts: NaiveDateTime.t()
        }
  defstruct [:ticker, :price, :ts]
end

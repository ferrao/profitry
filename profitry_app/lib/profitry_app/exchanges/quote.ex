defmodule ProfitryApp.Exchanges.Quote do
  @type t :: %__MODULE__{
          ticker: String.t(),
          price: Decimal.t(),
          timestamp: DateTime.t()
        }
  defstruct [:ticker, :price, :timestamp]
end

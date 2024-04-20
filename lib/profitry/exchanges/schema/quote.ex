defmodule Profitry.Exchanges.Schema.Quote do
  @moduledoc """

  Schema representing a stock or option quote 

  """

  @type t :: %__MODULE__{
          ticker: String.t(),
          price: Decimal.t(),
          timestamp: DateTime.t()
        }

  defstruct [:ticker, :price, :timestamp]
end

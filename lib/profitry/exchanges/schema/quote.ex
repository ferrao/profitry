defmodule Profitry.Exchanges.Schema.Quote do
  @moduledoc """

  Schema representing a stock or option quote

  """

  @type t :: %__MODULE__{
          exchange: String.t(),
          ticker: String.t(),
          price: Decimal.t(),
          timestamp: DateTime.t()
        }

  defstruct [:exchange, :ticker, :price, :timestamp]
end

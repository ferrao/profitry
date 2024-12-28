defmodule Profitry.Exchanges.Schema.Quote do
  @moduledoc """

  Schema representing a stock or option quote

  """

  @type t :: %__MODULE__{
          exchange: String.t(),
          ticker: String.t(),
          price: Decimal.t(),
          timestamp: NaiveDateTime.t()
        }

  defstruct [:exchange, :ticker, :price, :timestamp]

  defimpl String.Chars do
    @impl true
    def to_string(quote) do
      "Quote<#{quote.exchange}:#{quote.ticker} $#{quote.price} @ #{NaiveDateTime.to_string(quote.timestamp)}>"
    end
  end
end

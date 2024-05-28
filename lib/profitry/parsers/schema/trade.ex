defmodule Profitry.Parsers.Schema.Trade do
  @moduledoc """

  Schema respresenting a trade on a broker activity report

  """

  @type option_trade :: %{contract: :put | :call, strike: Decimal.t(), expiration: Date.t()}

  @type t :: %__MODULE__{
          asset: String.t(),
          currency: String.t(),
          ticker: String.t(),
          quantity: Decimal.t(),
          price: Decimal.t(),
          ts: NaiveDateTime.t(),
          option: option_trade | nil
        }

  defstruct [
    :asset,
    :currency,
    :ticker,
    :quantity,
    :price,
    :ts,
    option: nil
  ]
end

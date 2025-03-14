defmodule Profitry.Import.Trades do
  @moduledoc """

  Converts imported trades into attribute maps ready to be used with the Investment context

  """

  alias Profitry.Import.Parsers.Schema.Trade

  @type option_attrs :: %{
          type: String.t(),
          strike: String.t(),
          expiration: String.t()
        }
  @type attrs :: %{
          optional(:option) => option_attrs(),
          ticker: String.t(),
          type: String.t(),
          instrument: String.t(),
          quantity: String.t(),
          price: String.t(),
          fees: String.t(),
          inserted_at: String.t()
        }

  @doc """

  Converts a Trade map into an attributes map

  ## Examples

    iex> convert(%Trade{})
    %{field: value}

  """
  @spec convert(Trade.t()) :: attrs()
  def convert(trade = %Trade{option: nil}) do
    %{
      ticker: trade.ticker,
      type: order_type(trade.quantity),
      instrument: to_string(trade.asset),
      quantity: Decimal.abs(trade.quantity) |> Decimal.to_string(),
      price: Decimal.to_string(trade.price),
      fees: Decimal.to_string(trade.fees),
      inserted_at: NaiveDateTime.to_string(trade.ts)
    }
  end

  @spec convert(Trade.t()) :: attrs()
  def convert(trade = %Trade{}) do
    order = convert(%Trade{trade | option: nil})
    Map.put(order, :option, convert_option(trade.option))
  end

  @doc false
  @spec convert_option(Trade.option_trade()) :: option_attrs()
  defp convert_option(option) do
    %{
      type: to_string(option.contract),
      strike: Decimal.to_string(option.strike),
      expiration: Date.to_string(option.expiration)
    }
  end

  @doc false
  @spec order_type(Decimal.t()) :: String.t()
  defp order_type(quantity) do
    if Decimal.lt?(quantity, 0), do: "sell", else: "buy"
  end
end

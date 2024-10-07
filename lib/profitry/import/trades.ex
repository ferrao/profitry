defmodule Profitry.Import.Trades do
  alias Profitry.Import.Parsers.Schema.Trade

  def convert(trade = %Trade{option: nil}) do
    %{
      ticker: trade.ticker,
      type: order_type(trade.quantity),
      instrument: to_string(trade.asset),
      quantity: Decimal.abs(trade.quantity) |> Decimal.to_string(),
      price: Decimal.to_string(trade.price),
      inserted_at: NaiveDateTime.to_string(trade.ts)
    }
  end

  def convert(trade = %Trade{}) do
    order = convert(%Trade{trade | option: nil})
    Map.put(order, :option, convert_option(trade.option))
  end

  defp convert_option(option) do
    %{
      type: to_string(option.contract),
      strike: Decimal.to_string(option.strike),
      expiration: Date.to_string(option.expiration)
    }
  end

  defp order_type(quantity) do
    if Decimal.lt?(quantity, 0), do: "sell", else: "buy"
  end
end

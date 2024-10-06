defmodule Profitry.Import.Trades do
  alias Profitry.Import.Parsers.Schema.Trade
  alias Profitry.Investment.Schema.{Order, Option}

  def convert(trade = %Trade{option: nil}) do
    %Order{
      type: order_type(trade.quantity),
      instrument: trade.asset,
      quantity: Decimal.abs(trade.quantity),
      price: trade.price,
      inserted_at: trade.ts,
      option: nil
    }
  end

  def convert(trade = %Trade{}) do
    order = convert(%Trade{trade | option: nil})
    %Order{order | option: convert_option(trade.option)}
  end

  defp convert_option(option) do
    %Option{
      type: option.contract,
      strike: option.strike,
      expiration: option.expiration
    }
  end

  defp order_type(quantity) do
    if Decimal.lt?(quantity, 0), do: :sell, else: :buy
  end
end

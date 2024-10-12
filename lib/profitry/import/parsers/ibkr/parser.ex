defmodule Profitry.Import.Parsers.Ibkr.Parser do
  @moduledoc """

  Parser for Interactive Brokers activity statement

  """

  alias Profitry.Import.Parsers.Schema.Trade
  alias NimbleCSV.RFC4180, as: CSV
  alias Profitry.Utils.Date, as: DateUtils

  @stock "Stocks"
  @option "Equity and Index Options"

  @doc """

  Parses an activity statement

  ## Examples

    iex> parse("ibkr_activity_statement-2021.csv")
    [%Trade{}, %Trade{}]

  """
  @spec parse(String.t()) :: list(Trade.t())
  def parse(file) do
    file
    |> File.stream!(read_ahead: 100_000)
    |> Stream.filter(fn row -> row =~ ~r/^Trades,(Data|Header)/ end)
    |> CSV.parse_stream()
    |> Stream.filter(fn [_, type | _] -> type !== "Header" end)
    |> Stream.map(fn [_, _, _, asset, currency, symbol, ts, quantity, price | _] ->
      parse_trade(asset, currency, symbol, quantity, price, ts)
    end)
    |> Enum.map(& &1)
  end

  @spec parse_trade(String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
          Trade.t()
  def parse_trade(_asset = @stock, currency, symbol, quantity, price, ts) do
    %Trade{
      asset: :stock,
      currency: currency,
      ticker: symbol,
      quantity: Decimal.new(quantity),
      price: Decimal.new(price),
      ts: parse_timestamp(ts),
      option: nil
    }
  end

  @spec parse_trade(String.t(), String.t(), String.t(), String.t(), String.t(), String.t()) ::
          Trade.t()
  def parse_trade(_asset = @option, currency, symbol, quantity, price, ts) do
    %Trade{
      asset: :option,
      currency: currency,
      ticker: symbol_to_ticker(symbol),
      quantity: Decimal.new(quantity),
      price: Decimal.new(price),
      ts: parse_timestamp(ts),
      option: %{
        contract: symbol_to_contract(symbol),
        strike: symbol_to_strike(symbol),
        expiration: symbol_to_expiration(symbol)
      }
    }
  end

  @spec symbol_to_ticker(String.t()) :: String.t()
  def symbol_to_ticker(symbol),
    do:
      symbol
      |> String.split()
      |> List.first()

  @spec symbol_to_contract(String.t()) :: atom()
  def symbol_to_contract(symbol) do
    contract =
      String.split(symbol)
      |> List.pop_at(3)
      |> Tuple.to_list()
      |> List.first()

    case contract do
      "C" -> :call
      "P" -> :put
    end
  end

  @spec symbol_to_strike(String.t()) :: Decimal.t()
  def symbol_to_strike(symbol),
    do:
      symbol
      |> String.split()
      |> List.pop_at(2)
      |> Tuple.to_list()
      |> List.first()
      |> Decimal.new()

  @spec symbol_to_expiration(String.t()) :: Date.t()
  def symbol_to_expiration(symbol) do
    symbol
    |> String.split()
    |> List.pop_at(1)
    |> Tuple.to_list()
    |> List.first()
    |> DateUtils.parse_expiration!()
  end

  @spec parse_timestamp(String.t()) :: NaiveDateTime.t()
  defp parse_timestamp(ts), do: ts |> String.replace(",", "") |> NaiveDateTime.from_iso8601!()
end

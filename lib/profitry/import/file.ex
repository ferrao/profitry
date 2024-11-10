defmodule Profitry.Import.File do
  @moduledoc """

    Processes a broker statement file

  """

  alias Profitry.{Repo, Investment}
  alias Profitry.Investment.Schema.{Position, Portfolio, Order}
  alias Profitry.Import.Trades
  alias Profitry.Import.Parsers.Ibkr.Parser
  alias Profitry.Import.Parsers.Schema.Trade

  @doc """

  Processes a broker statement file, by importing all the positions and orders into a portfolio

  """
  @spec process(integer(), String.t()) :: list(Order.t())
  def process(portfolio_id, file) do
    portfolio = portfolio_with_positions(portfolio_id)
    trades = Parser.parse(file)
    tickers = trade_tickers(trades)
    create_positions(portfolio, tickers)
    portfolio = portfolio_with_positions(portfolio_id)

    trades
    |> Enum.map(&Trades.convert/1)
    |> Enum.map(fn order -> insert_order(portfolio.positions, order) end)
    |> Enum.map(fn {:ok, order} -> order end)
  end

  @doc false
  @spec portfolio_with_positions(integer()) :: Portfolio.t()
  def portfolio_with_positions(portfolio_id) do
    Repo.get(Portfolio, portfolio_id)
    |> Repo.preload(:positions)
  end

  @doc false
  @spec trade_tickers(list(Trade.t())) :: list(String.t())
  def trade_tickers(trades) do
    Enum.map(trades, fn trade -> trade.ticker end)
    |> Enum.uniq()
  end

  @doc false
  @spec create_positions(Portfolio.t(), list(String.t())) :: list(Position.t())
  def create_positions(portfolio, tickers) do
    portfolio_tickers =
      portfolio.positions
      |> Enum.map(fn position -> position.ticker end)

    tickers
    |> Enum.filter(fn ticker -> !Enum.member?(portfolio_tickers, ticker) end)
    |> Enum.map(fn ticker -> Investment.create_position(portfolio, %{ticker: ticker}) end)
    |> Enum.map(fn {:ok, position} -> position end)
  end

  @doc false
  @spec insert_order(list(Position.t()), Trades.attrs()) :: {:ok, Order.t()}
  def insert_order(positions, attrs) do
    position = Enum.find(positions, fn position -> position.ticker == attrs.ticker end)
    Investment.create_order(position, attrs)
  end
end

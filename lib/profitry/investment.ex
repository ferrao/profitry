defmodule Profitry.Investment do
  alias Profitry.Investment.{Portfolios, Positions, Orders, Splits, Reports, TickerChanges}

  @moduledoc """

    The Investment Context

  """
  defdelegate create_portfolio(attrs), to: Portfolios
  defdelegate list_portfolios(), to: Portfolios
  defdelegate get_portfolio!(id), to: Portfolios
  defdelegate update_portfolio(portfolio, attrs), to: Portfolios
  defdelegate delete_portfolio(portfolio), to: Portfolios
  defdelegate change_portfolio(portfolio, attrs \\ %{}), to: Portfolios
  defdelegate list_reports!(id, params \\ nil), to: Portfolios
  defdelegate position_closed?(position_report), to: Reports
  defdelegate list_tickers, to: Portfolios

  defdelegate create_position(portfolio, attrs), to: Positions
  defdelegate update_position(position, attrs), to: Positions
  defdelegate delete_position(position), to: Positions
  defdelegate change_position(position, attrs \\ %{}), to: Positions
  defdelegate get_position!(id), to: Positions
  defdelegate find_portfolio_position(portfolio, ticker), to: Positions
  defdelegate preload_orders(position), to: Positions
  defdelegate make_report(position, quote), to: Positions
  defdelegate make_report(position), to: Positions

  defdelegate create_order(position, attrs), to: Orders
  defdelegate list_orders_by_insertion(position), to: Orders
  defdelegate get_order(id), to: Orders
  defdelegate update_order(order, attrs), to: Orders
  defdelegate delete_order(order), to: Orders
  defdelegate change_order(order, attrs \\ %{}), to: Orders

  defdelegate create_split(attrs), to: Splits
  defdelegate update_split(split, attr), to: Splits
  defdelegate delete_split(split), to: Splits
  defdelegate change_split(split, attrs \\ %{}), to: Splits
  defdelegate list_splits(), to: Splits
  defdelegate get_split!(id), to: Splits
  defdelegate find_splits(ticker), to: Splits

  defdelegate create_ticker_change(attrs), to: TickerChanges
  defdelegate update_ticker_change(ticker_change, attrs), to: TickerChanges
  defdelegate delete_ticker_change(ticker_change), to: TickerChanges
  defdelegate change_ticker_change(ticker_change, attrs \\ %{}), to: TickerChanges
  defdelegate list_ticker_changes(), to: TickerChanges
  defdelegate get_ticker_change!(id), to: TickerChanges
  defdelegate find_recent_ticker(ticker), to: TickerChanges
  defdelegate fetch_historical_tickers(ticker), to: TickerChanges
  defdelegate find_position_by_ticker(positions, ticker), to: TickerChanges
end

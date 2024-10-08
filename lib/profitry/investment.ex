defmodule Profitry.Investment do
  alias Profitry.Investment.{Portfolios, Positions, Orders, Splits, Reports}

  @moduledoc """

    The Investment Context

  """
  defdelegate create_portfolio(attrs), to: Portfolios
  defdelegate list_portfolios(), to: Portfolios
  defdelegate get_portfolio(id), to: Portfolios
  defdelegate update_portfolio(portfolio, attrs), to: Portfolios
  defdelegate delete_portfolio(portfolio), to: Portfolios

  defdelegate create_position(portfolio, attrs), to: Positions
  defdelegate update_position(position, attrs), to: Positions
  defdelegate delete_position(position), to: Positions

  defdelegate create_order(position, attrs), to: Orders
  defdelegate list_orders(position), to: Orders
  defdelegate get_order(id), to: Orders
  defdelegate update_order(order, attrs), to: Orders
  defdelegate delete_order(order), to: Orders

  defdelegate create_split(attrs), to: Splits
  defdelegate update_split(split, attr), to: Splits
  defdelegate delete_split(split), to: Splits
  defdelegate list_splits(), to: Splits
  defdelegate find_splits(ticker), to: Splits

  defdelegate make_report(position, quote), to: Reports
  defdelegate make_report(position), to: Reports
end

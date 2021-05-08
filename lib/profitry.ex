defmodule Profitry do
  alias Profitry.{Report, Portfolio}

  defdelegate new_portfolio(id, description), to: Portfolio
  defdelegate make_order(portfolio, ticker, order), to: Portfolio
  defdelegate new_position(portfolio, ticker, order), to: Portfolio

  defdelegate make_report(position), to: Report
end

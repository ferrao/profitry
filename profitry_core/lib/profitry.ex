defmodule Profitry.Core do
  alias Profitry.Core.Portfolio

  defdelegate new_portfolio(id, description), to: Portfolio
  defdelegate make_order(portfolio, ticker, order), to: Portfolio
  defdelegate make_report(portfolio), to: Portfolio
end

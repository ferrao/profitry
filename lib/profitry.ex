defmodule Profitry do
  alias Profitry.{Portfolio, StockOrder, OptionsOrder}

  @type order :: :buy | :sell

  @spec new_portfolio(atom(), String.t()) :: Portfolio.t()
  defdelegate new_portfolio(id, description), to: Portfolio

  @spec make_order(Portfolio.t(), String.t(), StockOrder.t() | OptionsOrder.t()) :: Portfolio.t()
  defdelegate make_order(portfolio, ticker, order), to: Portfolio

  @spec make_report(Portfolio.t()) :: list(Report.t())
  defdelegate make_report(portfolio), to: Portfolio
end

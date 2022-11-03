defmodule Profitry do
  alias Profitry.Application.Server
  alias Profitry.Domain.{Report, StockOrder, OptionsOrder}

  @type order :: :buy | :sell

  @spec list_portfolios() :: list({atom(), String.t()})
  defdelegate list_portfolios, to: Server

  @spec new_portfolio(atom(), String.t()) :: atom()
  defdelegate new_portfolio(id, description), to: Server

  @spec make_order(atom(), String.t(), StockOrder.t() | OptionsOrder.t()) :: atom()
  defdelegate make_order(id, ticker, order), to: Server

  @spec report(atom()) :: list(Report.t())
  defdelegate report(id), to: Server
end

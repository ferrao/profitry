defmodule Profitry do
  alias Profitry.Application.{Server, App}
  alias Profitry.Domain.{Report, StockOrder, OptionsOrder}

  @type order :: :buy | :sell
  @opaque server :: Server.t()

  @spec start_server() :: server
  def start_server() do
    {:ok, pid} = App.start_server()
    pid
  end

  @spec list_portfolios(server()) :: list({atom(), String.t()})
  defdelegate list_portfolios(server), to: Server

  @spec new_portfolio(server(), atom(), String.t()) :: atom()
  defdelegate new_portfolio(server, id, description), to: Server

  @spec make_order(server(), atom(), String.t(), StockOrder.t() | OptionsOrder.t()) :: atom()
  defdelegate make_order(server, id, ticker, order), to: Server

  @spec report(server(), atom()) :: list(Report.t())
  defdelegate report(server, id), to: Server
end

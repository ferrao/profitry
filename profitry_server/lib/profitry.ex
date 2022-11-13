defmodule Profitry do
  alias Profitry.Application.{Server, App}
  alias Profitry.Domain.{Portfolio, Report, StockOrder, OptionsOrder}

  @type order :: :buy | :sell
  @type portfolio :: Portfolio.t()
  @opaque server :: Server.t()

  @spec start_server() :: server
  def start_server() do
    {:ok, pid} = App.start_server()
    pid
  end

  @spec list_portfolios(server()) :: list({atom(), String.t()})
  def list_portfolios(server) do
    GenServer.call(server, {:list_portfolios})
  end

  @spec get_portfolio(server(), atom()) :: Portfolio.t()
  def get_portfolio(server, id) do
    GenServer.call(server, {:get_portfolio, id})
  end

  @spec new_portfolio(server(), atom(), String.t()) :: atom()
  def new_portfolio(server, id, name) do
    GenServer.call(server, {:new_portfolio, id, name})
  end

  @spec make_order(server(), atom(), String.t(), StockOrder.t() | OptionsOrder.t()) :: atom()
  def make_order(server, id, ticker, order) do
    GenServer.call(server, {:make_order, id, ticker, order})
  end

  @spec report(server(), atom()) :: list(Report.t())
  def report(server, id) do
    GenServer.call(server, {:report, id})
  end
end

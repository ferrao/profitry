defmodule Profitry.Application.Server do
  alias Profitry.Domain.{Report, Portfolio, StockOrder, OptionsOrder}

  @type t :: pid

  use Agent

  @spec start_link(any()) :: {atom(), pid()}
  def start_link(_) do
    Agent.start_link(fn -> [] end)
  end

  @spec list(t()) :: list(Portfolio.t())
  def list(server) do
    Agent.get(server, fn state -> state end)
  end

  @spec get(t(), atom()) :: Portfolio.t()
  def get(server, key) do
    Agent.get(server, fn state -> state |> Enum.find(fn portfolio -> portfolio.id == key end) end)
  end

  @spec set(t(), Portfolio.t()) :: atom()
  def set(server, portfolio) do
    Agent.update(server, fn state ->
      [portfolio | state |> Enum.filter(fn e -> e.id != portfolio.id end)]
    end)
  end

  @spec new_portfolio(t(), atom(), String.t()) :: atom()
  def new_portfolio(server, id, description) do
    portfolio = Portfolio.new_portfolio(id, description)
    set(server, portfolio)
  end

  @spec list_portfolios(t()) :: list({atom(), String.t()})
  def list_portfolios(server) do
    list(server)
    |> Enum.map(fn portfolio -> {portfolio.id, portfolio.description} end)
  end

  @spec make_order(t(), atom(), String.t(), StockOrder.t() | OptionsOrder.t()) :: atom()
  def make_order(server, id, ticker, order) do
    portfolio = get(server, id) |> Portfolio.make_order(ticker, order)
    set(server, portfolio)
  end

  @spec report(t(), atom()) :: list(Report.t())
  def report(server, id) do
    get(server, id) |> Portfolio.make_report()
  end
end

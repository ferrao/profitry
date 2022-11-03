defmodule Profitry.Application.Server do
  alias Profitry.Domain.{Report, Portfolio, StockOrder, OptionsOrder}

  @me __MODULE__

  @spec start() :: {atom(), pid()}
  def start do
    Agent.start_link(fn -> [] end, name: @me)
  end

  @spec list() :: list(Portfolio.t())
  def list() do
    Agent.get(@me, fn state -> state end)
  end

  @spec get(atom()) :: Portfolio.t()
  def get(key) do
    Agent.get(@me, fn state -> state |> Enum.find(fn portfolio -> portfolio.id == key end) end)
  end

  @spec set(Portfolio.t()) :: atom()
  def set(portfolio) do
    Agent.update(@me, fn state ->
      [portfolio | state |> Enum.filter(fn e -> e.id != portfolio.id end)]
    end)
  end

  @spec new_portfolio(atom(), String.t()) :: atom()
  def new_portfolio(id, description) do
    Portfolio.new_portfolio(id, description)
    |> set
  end

  @spec list_portfolios() :: list({atom(), String.t()})
  def list_portfolios() do
    list()
    |> Enum.map(fn portfolio -> {portfolio.id, portfolio.description} end)
  end

  @spec make_order(atom(), String.t(), StockOrder.t() | OptionsOrder.t()) :: atom()
  def make_order(id, ticker, order) do
    id
    |> get
    |> Portfolio.make_order(ticker, order)
    |> set
  end

  @spec report(atom()) :: list(Report.t())
  def report(id) do
    id
    |> get
    |> Portfolio.make_report()
  end
end

defmodule Profitry.Application.Server do
  alias Profitry.Domain.Portfolio

  @type t :: pid

  use GenServer

  # Client Process
  def start_link(_) do
    GenServer.start(__MODULE__, nil)
  end

  # Server Process
  def init(_) do
    {:ok, []}
  end

  def handle_call({:list_portfolios}, _from, state) do
    portfolio_list = state |> Enum.map(fn portfolio -> {portfolio.id, portfolio.description} end)
    {:reply, portfolio_list, state}
  end

  def handle_call({:new_portfolio, id, description}, _from, state) do
    new_portfolio = Portfolio.new_portfolio(id, description)
    updated_state = set(state, new_portfolio)

    {:reply, :ok, updated_state}
  end

  def handle_call({:make_order, id, ticker, order}, _from, state) do
    portfolio = get(state, id) |> Portfolio.make_order(ticker, order)
    {:reply, :ok, set(state, portfolio)}
  end

  def handle_call({:report, id}, _from, state) do
    report = get(state, id) |> Portfolio.make_report()
    {:reply, report, state}
  end

  # GenServer state helpers 
  defp get(state, id) do
    state |> Enum.find(fn portfolio -> portfolio.id == id end)
  end

  defp set(state, portfolio) do
    [
      portfolio | state |> Enum.filter(fn e -> e.id != portfolio.id end)
    ]
  end
end

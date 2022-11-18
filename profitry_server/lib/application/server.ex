defmodule Profitry.Application.Server do
  alias Profitry.Domain.Portfolio

  @type t :: pid
  @type state_t :: list(Portfolio.t())

  use GenServer

  # Client Process
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  # Server Process
  def init(_) do
    {:ok, []}
  end

  def handle_call({:list_portfolios}, _from, state) do
    portfolio_list = state |> Enum.map(fn portfolio -> {portfolio.id, portfolio.name} end)

    {:reply, portfolio_list, state}
  end

  def handle_call({:get_portfolio, id}, _from, state) do
    portfolio = state |> Enum.find(fn p -> p.id == id end)
    {:reply, portfolio, state}
  end

  def handle_call({:new_portfolio, id, name}, _from, state) do
    new_portfolio = Portfolio.new_portfolio(id, name)
    updated_state = set_portfolio(state, new_portfolio)

    {:reply, :ok, updated_state}
  end

  def handle_call({:make_order, id, ticker, order}, _from, state) do
    portfolio = get_portfolio(state, id) |> Portfolio.make_order(ticker, order)
    {:reply, :ok, set_portfolio(state, portfolio)}
  end

  def handle_call({:report, id}, _from, state) do
    report = get_portfolio(state, id) |> Portfolio.make_report()
    {:reply, report, state}
  end

  def handle_call({:save, path}, _from, state) do
    {:ok, json} = state |> Poison.encode()

    case File.stat(path) do
      {:error, :enoent} ->
        File.write(path, json, [:exclusive])
        {:reply, :ok, state}

      _ ->
        {:reply, :error, state}
    end
  end

  def handle_call({:load, path}, _from, state) do
    case File.stat(path) do
      {:error, :enoent} ->
        {:reply, :error, state}

      _ ->
        {:ok, json} = path |> File.read()
        {:ok, state} = Poison.decode(json, %{as: [%Portfolio{}], keys: :atoms})

        {:reply, :ok, state}
    end
  end

  # GenServer state helpers 
  defp get_portfolio(state, id) do
    state |> Enum.find(fn portfolio -> portfolio.id == id end)
  end

  defp set_portfolio(state, portfolio) do
    [
      portfolio | state |> Enum.filter(fn e -> e.id != portfolio.id end)
    ]
  end
end

defmodule Profitry.Exchanges.Subscribers.HistorySubscriber do
  @moduledoc """

  Maintains the last quote data from exchanges

  """
  use GenServer

  require Logger

  alias Profitry.Exchanges
  alias Profitry.Exchanges.Schema.Quote

  @type t() :: %__MODULE__{
          backlog_size: integer(),
          quotes: %{String.t() => list(Quote.t())},
          topics: Exchanges.topics() | nil
        }
  defstruct [:backlog_size, :quotes, :topics]

  @doc """

  Starts the history subscriber

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    backlog_size = Keyword.get(opts, :backlog_size, 1)
    server_name = Keyword.get(opts, :name, __MODULE__)
    topics = Keyword.get(opts, :topics, nil)

    GenServer.start_link(__MODULE__, {backlog_size, topics}, name: server_name)
  end

  @impl GenServer
  def init({backlog_size, topics}) do
    {:ok,
     %__MODULE__{
       backlog_size: backlog_size,
       quotes: %{},
       topics: topics
     }, {:continue, :subscribe}}
  end

  @impl GenServer
  def handle_continue(:subscribe, %{topics: nil} = state) do
    Exchanges.subscribe_quotes()
    Exchanges.subscribe_ticker_updates()
    {:noreply, state}
  end

  @impl GenServer
  def handle_continue(:subscribe, %{topics: topics} = state) do
    Exchanges.subscribe_quotes(topics[:quotes])
    Exchanges.subscribe_ticker_updates(topics[:ticker_updates])
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:ticker_config_changed}, state) do
    # A ticker change was updated/deleted. Restarting is the simplest way to
    # flush the cache and ensure consistency with the new rules.
    Logger.warning("Ticker configuration changed. Restarting history subscriber to flush cache.")

    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_info({:ticker_changed, old, new}, state) do
    Logger.info("Migrating history for ticker #{old} to #{new}.")

    case Map.get(state.quotes, old) do
      nil ->
        # No history for the old ticker, do nothing
        {:noreply, state}

      old_quotes ->
        # Combine old history with the new ticker's existing history (if any)
        new_ticker_existing_quotes = Map.get(state.quotes, new, [])

        combined_quotes =
          (new_ticker_existing_quotes ++ old_quotes)
          |> Enum.uniq()
          |> Enum.take(state.backlog_size)

        new_quotes_map = Map.put(state.quotes, new, combined_quotes)
        {:noreply, %{state | quotes: new_quotes_map}}
    end
  end

  @impl GenServer
  def handle_info({:new_quote, quote}, state) do
    ticker_quotes = Map.get(state.quotes, quote.ticker) || []
    new_ticker_quotes = [quote | ticker_quotes] |> Enum.take(state.backlog_size)

    new_quotes = Map.put(state.quotes, quote.ticker, new_ticker_quotes)
    new_state = Map.put(state, :quotes, new_quotes)

    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:list_quotes, ticker}, _from, state) do
    {:reply, Map.get(state.quotes, ticker), state}
  end

  @doc """

  Lists the quotes for a ticker

  """
  @spec list_quotes(GenServer.server(), String.t()) :: list(Quote.t())
  def list_quotes(pid \\ __MODULE__, ticker) do
    GenServer.call(pid, {:list_quotes, ticker}) || []
  end

  @doc """

  Gets the last quote for a ticker

  """
  @spec get_quote(GenServer.server(), String.t()) :: Quote.t() | nil
  def get_quote(pid \\ __MODULE__, ticker) do
    list_quotes(pid, ticker) |> List.first()
  end
end

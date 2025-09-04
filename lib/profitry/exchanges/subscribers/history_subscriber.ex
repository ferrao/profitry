defmodule Profitry.Exchanges.Subscribers.HistorySubscriber do
  @moduledoc """

  Maintains the last quote data from exchanges

  """
  use GenServer

  alias Profitry.Exchanges
  alias Profitry.Exchanges.Schema.Quote

  @type t() :: %__MODULE__{
          backlog_size: integer(),
          quotes: %{String.t() => list(Quote.t())},
          topic: String.t()
        }
  defstruct [:backlog_size, :quotes, :topic]

  @doc """

  Starts the history subscriber

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    backlog_size = Keyword.get(opts, :backlog_size, 1)
    server_name = Keyword.get(opts, :name, __MODULE__)
    topic = Keyword.get(opts, :topic, nil)

    GenServer.start_link(__MODULE__, {backlog_size, topic}, name: server_name)
  end

  @impl GenServer
  def init({backlog_size, topic}) do
    {:ok,
     %__MODULE__{
       backlog_size: backlog_size,
       quotes: %{},
       topic: topic
     }, {:continue, :subscribe}}
  end

  @impl GenServer
  def handle_continue(:subscribe, %__MODULE__{topic: nil} = state) do
    Exchanges.subscribe_quotes()
    {:noreply, state}
  end

  @impl GenServer
  def handle_continue(:subscribe, %__MODULE__{topic: topic} = state) do
    Exchanges.subscribe_quotes(topic)
    {:noreply, state}
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

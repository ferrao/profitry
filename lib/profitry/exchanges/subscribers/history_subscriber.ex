defmodule Profitry.Exchanges.Subscribers.HistorySubscriber do
  @moduledoc """

  Maintains the last quote data from exchanges

  """
  use GenServer

  alias Profitry.Exchanges
  alias Profitry.Exchanges.Schema.Quote

  @type t() :: %__MODULE__{
          backlog_size: integer(),
          quotes: %{String.t() => list(Quote.t())}
        }
  defstruct [:backlog_size, :quotes]

  @doc """

  Starts the history subscriber

  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    backlog_size = Keyword.get(opts, :backlog_size, 1)

    GenServer.start_link(__MODULE__, backlog_size, name: __MODULE__)
  end

  @impl true
  def init(backlog_size) do
    {:ok,
     %__MODULE__{
       backlog_size: backlog_size,
       quotes: %{}
     }, {:continue, :subscribe}}
  end

  @impl true
  def handle_continue(:subscribe, history) do
    Exchanges.subscribe_quotes()
    {:noreply, history}
  end

  @impl true
  def handle_info({:new_quote, quote}, history) do
    ticker_quotes = Map.get(history.quotes, quote.ticker) || []
    new_ticker_quotes = [quote | ticker_quotes] |> Enum.take(history.backlog_size)

    new_quotes = Map.put(history.quotes, quote.ticker, new_ticker_quotes)
    new_history = Map.put(history, :quotes, new_quotes )

    {:noreply, new_history}
  end

  @impl true
  def handle_call({:list_quotes, ticker}, _from, history) do
    {:reply, Map.get(history.quotes, ticker), history}
  end

  @doc """

  Lists the quotes for a ticker

  """
  @spec list_quotes(GenServer.server(), String.t()) :: list(Quote.t())
  def list_quotes(pid \\ __MODULE__, ticker) do
    GenServer.call(pid, {:list_quotes, ticker})
  end

  @doc """

  Gets the last quote for a ticker

  """
  @spec get_quote(GenServer.server(), String.t()) :: Quote.t()
  def get_quote(pid \\ __MODULE__, ticker) do
    list_quotes(pid, ticker) |> List.first()
  end
end

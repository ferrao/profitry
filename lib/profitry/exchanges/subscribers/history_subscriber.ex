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

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    backlog_size = Keyword.get(opts, :tickers, 1)

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
    new_history = Map.put(history, quote.ticker, [quote | quote.ticker])
    {:noreply, new_history}
  end

  @impl true
  def handle_call({:get_quote, ticker}, _from, history) do
    {:reply, Map.get(history, ticker) |> List.first(), history}
  end

  @doc """

  Gets the last quote for a ticker

  """
  @spec get_quote(GenServer.server(), String.t()) :: Quote.t()
  def get_quote(pid \\ __MODULE__, ticker) do
    GenServer.call(pid, {:get_quote, ticker})
  end
end

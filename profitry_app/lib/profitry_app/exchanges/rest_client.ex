defmodule ProfitryApp.Exchanges.RestClient do
  use GenServer

  require Logger

  alias ProfitryApp.Exchanges
  alias ProfitryApp.Exchanges.Quote

  @type t :: %__MODULE__{
          tickers: [String.t()],
          index: Integer.t(),
          client: module()
        }
  defstruct [:tickers, :index, :client]

  @callback interval() :: Integer.t()
  @callback quote(String.t()) :: {:ok, Quote.t()} | {:error, any()}

  def start_link(module) do
    GenServer.start_link(__MODULE__, module, name: module)
  end

  def child_spec(client) do
    %{
      id: client,
      start: {__MODULE__, :start_link, [client]}
    }
  end

  @impl true
  def init(module) do
    state = %__MODULE__{
      tickers: [],
      index: 0,
      client: module
    }

    {:ok, state, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, state) do
    {:noreply, %{state | tickers: Exchanges.list_tickers()}, {:continue, :start}}
  end

  def handle_continue(:start, state) do
    ProfitryApp.subscribe_updates()
    send(self(), :tick)

    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{tickers: []} = state) do
    Process.send_after(self(), :tick, interval(state.client))
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{tickers: tickers, index: index} = state) do
    fetch_quote(state.client, Enum.at(tickers, index))
    |> handle_quote

    Process.send_after(self(), :tick, interval(state.client))
    {:noreply, %{state | index: rem(index + 1, length(tickers))}}
  end

  @impl true
  def handle_info(:reset, state) do
    Logger.info("Fetching new ticker list")

    {:noreply, %{state | tickers: Exchanges.list_tickers(), index: 0}}
  end

  @impl true
  def handle_info(ticker, state) when is_binary(ticker) do
    Logger.info("Adding #{ticker} to ticker list")

    {:noreply, %{state | tickers: [ticker | state.tickers]}}
  end

  defp handle_quote({:ok, quote}) do
    ProfitryApp.broadcast_quote(quote)
  end

  defp handle_quote({:error, reason}), do: Logger.warn("Unable to fetch quote: #{reason}")

  defp fetch_quote(client, ticker), do: client.quote(ticker)

  defp interval(client), do: client.interval()
end

defmodule Profitry.Exchanges.PollServer do
  @moduledoc """

  Gen server that polls exchanges for quotes to publish on pubsub

  """
  use GenServer

  require Logger

  alias Profitry.Exchanges.Schema.Quote

  defstruct [:tickers, :index, :client]

  @doc """

    Starts the poll server process for the given exchange module

  """
  @spec start(module()) :: GenServer.on_start()
  def start(module) do
    GenServer.start_link(__MODULE__, module, name: module)
  end

  @doc """

  Allows a supervisor to retreive this server child spec

  """
  @spec child_spec(module()) :: Supervisor.child_spec()
  def child_spec(module), do: %{id: module, start: {__MODULE__, :start, [module]}}

  @impl true
  def init(exchange) do
    state = %__MODULE__{
      tickers: [],
      index: 0,
      client: exchange
    }

    {:ok, state, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, state) do
    {:noreply, %{state | tickers: Profitry.list_tickers()}, {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    send(self(), :tick)
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{tickers: []} = state) do
    Process.send_after(self(), :tick, interval(state.client))
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{index: index, tickers: tickers} = state) do
    fetch_quote(state.client, Enum.at(tickers, index))
    |> handle_quote

    Process.send_after(self(), :tick, interval(state.client))
    {:noreply, %{state | index: rem(index + 1, length(tickers))}}
  end

  @spec handle_quote({atom(), Quote.t()}) :: :ok | {:error, any()}
  defp handle_quote({:ok, %Quote{} = quote}) do
    Profitry.broadcast_quote(quote)
  end

  @spec handle_quote({atom(), any()}) :: :ok
  defp handle_quote({:error, reason}), do: Logger.warning("Unable to fetch quote: #{reason}")

  @spec interval(module()) :: integer()
  defp interval(client), do: client.interval()

  @spec fetch_quote(module(), String.t()) :: {:ok, Quote.t()} | {:error, any()}
  defp fetch_quote(client, ticker), do: client.quote(ticker)
end

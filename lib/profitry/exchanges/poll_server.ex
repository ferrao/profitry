defmodule Profitry.Exchanges.PollServer do
  @moduledoc """

  Gen server that polls exchanges for quotes to publish on pubsub

  """
  use GenServer

  require Logger

  alias Profitry.Exchanges.Schema.Quote

  defstruct [:tickers, :interval, :index, :warm, :client, :client_opts]

  @fast_start 1000

  @doc """

    Starts the poll server process for the given exchange module

  """
  @spec start_link(module(), keyword()) :: GenServer.on_start()
  def start_link(exchange_client, opts \\ []) do
    tickers = Keyword.get(opts, :tickers, [])
    interval = Keyword.get(opts, :interval, interval(exchange_client))

    GenServer.start_link(__MODULE__, {exchange_client, tickers, interval}, name: exchange_client)
  end

  @doc """

  Allows a supervisor to retreive this server child spec

  """
  @spec child_spec({module(), list(String.t())}) :: Supervisor.child_spec()
  def child_spec({exchange_client, tickers}) do
    %{
      id: exchange_client,
      start: {__MODULE__, :start_link, [exchange_client, tickers]}
    }
  end

  @impl true
  def init({exchange_client, tickers, interval}) do
    state = %__MODULE__{
      tickers: tickers,
      interval: interval,
      index: 0,
      warm: false,
      client: exchange_client,
      client_opts: exchange_client.init()
    }

    {:ok, state, {:continue, :start}}
  end

  @impl true
  def handle_continue(:start, state) do
    send(self(), :tick)
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{tickers: [], interval: interval} = state) do
    Process.send_after(self(), :tick, interval)
    {:noreply, state}
  end

  @impl true
  def handle_info(
        :tick,
        %{index: index, tickers: tickers, interval: interval, client_opts: options, warm: warm} =
          state
      ) do
    fetch_quote(state.client, Enum.at(tickers, index), options)
    |> handle_quote

    interval = if warm, do: interval, else: @fast_start

    Process.send_after(self(), :tick, interval)

    {:noreply,
     %{
       state
       | warm: is_warm?(warm, index, length(tickers)),
         index: rem(index + 1, length(tickers))
     }}
  end

  @spec handle_quote({:error, any()}) :: :ok
  defp handle_quote({:error, reason}), do: Logger.warning("Unable to fetch quote: #{reason}")

  @spec handle_quote({:ok, Quote.t()}) :: :ok | {:error, any()}
  defp handle_quote({:ok, %Quote{} = quote}) do
    Profitry.broadcast_quote(quote)
  end

  @spec interval(module()) :: integer()
  defp interval(exchange_client), do: exchange_client.interval()

  @spec fetch_quote(module(), String.t(), keyword()) :: {:ok, Quote.t()} | {:error, any()}
  defp fetch_quote(exchange_client, ticker, options), do: exchange_client.quote(ticker, options)

  @spec is_warm?(boolean(), integer(), integer()) :: integer()
  defp is_warm?(warm, index, length) do
    if !warm && index === length - 1 do
      true
    else
      warm
    end
  end
end

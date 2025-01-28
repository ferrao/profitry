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

  @doc """

  Initializes the server state

  """
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

  @doc """

  Starts server polling loop

  """
  @impl true
  def handle_continue(:start, state) do
    send(self(), :tick)
    {:noreply, state}
  end

  # tickers list is empty, just schedule another run
  @impl true
  def handle_info(:tick, %{tickers: [], interval: interval} = state) do
    Profitry.subscribe_ticker_updates()
    Process.send_after(self(), :tick, interval)
    {:noreply, state}
  end

  # fetch one quote from the ticker list and schedule another run
  @impl true
  def handle_info(:tick, state) do
    %{
      index: index,
      tickers: tickers,
      interval: interval,
      client_opts: options,
      warm: warm,
      client: client
    } = state

    fetch_quote(client, Enum.at(tickers, index), options)
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

  # add a new ticker to the list of tickers to fetch
  @impl true
  def handle_info(ticker, %{tickers: tickers} = state) when is_binary(ticker) do
    Logger.info("Adding #{ticker} to ticker list")

    {:noreply,
     %{state | tickers: update_tickers(tickers, ticker, !Enum.member?(tickers, ticker))}}
  end

  @spec update_tickers(list(String.t()), String.t(), boolean()) :: list(String.t())
  defp update_tickers(tickers, ticker, true), do: [ticker | tickers]
  defp update_tickers(tickers, _ticker, _update), do: tickers

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
    if !warm && index === length - 1, do: true, else: warm
  end
end

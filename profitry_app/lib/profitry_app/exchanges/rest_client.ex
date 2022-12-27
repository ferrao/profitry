defmodule ProfitryApp.Exchanges.RestClient do
  use GenServer

  require Logger

  alias Phoenix.PubSub
  alias ProfitryApp.Exchanges

  @interval 5000

  @impl true
  def init(_init_arg) do
    {:ok, %{tickers: [], index: 0}, {:continue, :load}}
  end

  @impl true
  def handle_continue(:load, state) do
    {:noreply, %{state | tickers: Exchanges.list_tickers()}, {:continue, :start}}
  end

  def handle_continue(:start, state) do
    send(self(), :tick)

    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{tickers: []} = state) do
    Process.send_after(self(), :tick, @interval)
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, %{tickers: tickers, index: index} = state) do
    fetch_quote(Enum.at(tickers, index))
    |> handle_quote

    Process.send_after(self(), :tick, @interval)
    {:noreply, %{state | index: rem(index + 1, length(tickers))}}
  end

  defp handle_quote({:ok, quote}) do
    PubSub.broadcast(ProfitryApp.PubSub, "quotes", quote)
  end

  defp handle_quote({:error, reason}), do: Logger.warn("Unable to fetch quote: #{reason}")

  defp fetch_quote(ticker), do: Exchanges.Finnhub.Client.quote(ticker)
end

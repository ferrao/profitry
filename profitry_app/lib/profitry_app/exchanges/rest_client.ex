defmodule ProfitryApp.Exchanges.RestClient do
  use GenServer

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
  def handle_info(:tick, %{tickers: tickers, index: index} = state) do
    fetch_quote(Enum.at(tickers, index))
    # We should publish the quote to pubsub
    |> IO.inspect()

    Process.send_after(self(), :tick, @interval)

    {:noreply, %{state | index: rem(index + 1, length(tickers))}}
  end

  defp fetch_quote(ticker), do: Exchanges.Finnhub.quote(ticker)
end

defmodule ProfitryApp.Exchanges.Finnhub do
  use GenServer

  alias ProfitryApp.Exchanges

  # Finnhub Mock quote 
  @quote %{
    c: 124.2579,
    d: -1.0921,
    dp: -0.8712,
    h: 128.6173,
    l: 121.02,
    o: 126.37,
    pc: 125.35,
    t: 1_671_825_922
  }

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

    Process.send_after(self(), :tick, 1000)

    {:noreply, %{state | index: index + 1}}
  end

  defp fetch_quote(_ticker), do: @quote
end

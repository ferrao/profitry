defmodule Profitry.Exchanges.Clients.DummyClient do
  @behaviour Profitry.Exchanges.PollBehaviour

  alias Profitry.Exchanges.Schema.Quote

  @interval :timer.seconds(2)

  @impl true
  def interval(), do: @interval

  @impl true
  def quote("TIMEOUT"), do: {:error, "Timeout"}

  @impl true
  def quote(ticker) do
    {:ok,
     %Quote{
       ticker: ticker,
       exchange: "Dummy",
       price: Decimal.from_float(300 * :rand.uniform()),
       timestamp: DateTime.utc_now()
     }}
  end
end

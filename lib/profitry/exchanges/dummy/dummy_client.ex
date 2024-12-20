defmodule Profitry.Exchanges.Dummy.DummyClient do
  @behaviour Profitry.Exchanges.PollBehaviour

  alias Profitry.Exchanges.Schema.Quote

  @impl true
  def interval(), do: 1000

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

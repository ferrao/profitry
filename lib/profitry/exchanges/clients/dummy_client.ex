defmodule Profitry.Exchanges.Clients.DummyClient do
  @moduledoc """

  Dummy Client for mocking an exchange

  """
  @behaviour Profitry.Exchanges.PollBehaviour

  alias Profitry.Exchanges.Schema.Quote

  @interval :timer.seconds(2)

  @impl true
  def init(), do: [dummy: true, real: false]

  @impl true
  def interval(), do: @interval

  @impl true
  def quote("TIMEOUT", _opts), do: {:error, "Timeout"}

  @impl true
  def quote(ticker, _opts) do
    {:ok,
     %Quote{
       ticker: ticker,
       exchange: "Dummy",
       price: Decimal.from_float(300 * :rand.uniform()),
       timestamp: DateTime.utc_now()
     }}
  end
end

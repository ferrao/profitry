defmodule ProfitryApp.Exchanges.Dummy.DummyClient do
  @behaviour ProfitryApp.Exchanges.RestClient

  alias ProfitryApp.Exchanges.Quote

  @impl true
  def interval(), do: 1000

  @impl true
  def quote("TIMEOUT"), do: {:error, "Timeout"}

  @impl true
  def quote(ticker) do
    {:ok,
     %Quote{
       ticker: ticker,
       price: Decimal.from_float(300 * :rand.uniform()),
       timestamp: DateTime.utc_now()
     }}
  end
end

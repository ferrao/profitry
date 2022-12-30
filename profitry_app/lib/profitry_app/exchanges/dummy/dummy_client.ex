defmodule ProfitryApp.Exchanges.Dummy.DummyClient do
  @behaviour ProfitryApp.Exchanges.RestClient

  alias ProfitryApp.Exchanges.Quote

  @impl true
  def interval(), do: 1000

  @impl true
  def quote("TEST_BAD"), do: {:error, "Timeout"}

  @impl true
  def quote(_ticker) do
    {:ok,
     %Quote{
       ticker: "TEST",
       price: 300 * :rand.uniform(),
       timestamp: DateTime.utc_now()
     }}
  end
end

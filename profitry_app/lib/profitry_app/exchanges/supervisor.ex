defmodule ProfitryApp.Exchanges.Supervisor do
  use Supervisor

  alias ProfitryApp.Exchanges.RestClient
  alias ProfitryApp.Exchanges.Finnhub.FinnhubClient
  alias ProfitryApp.Exchanges.Dummy.DummyClient

  def start_link(opts \\ []) when is_list(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {RestClient, FinnhubClient},
      {RestClient, DummyClient}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

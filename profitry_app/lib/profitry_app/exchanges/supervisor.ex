defmodule ProfitryApp.Exchanges.Supervisor do
  use Supervisor

  alias ProfitryApp.Exchanges.RestClient

  def start_link(opts \\ []) when is_list(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {RestClient, ProfitryApp.Exchanges.Finnhub.FinnhubClient}
      # {RestClient, ProfitryApp.Exchanges.Dummy.DummyClient}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule ProfitryApp.Exchanges.Supervisor do
  use Supervisor

  alias ProfitryApp.Exchanges.RestClient
  alias ProfitryApp.Exchanges.Finnhub.FinnhubClient

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      {RestClient, FinnhubClient}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Profitry.Exchanges.Supervisor do
  @moduledoc """

  Supervisor that starts and monitors exchange clients and subscribers

  """
  use Supervisor

  alias Profitry.Exchanges.{Clients, Subscribers}
  alias Profitry.Exchanges.PollServer

  @doc """

  Starts the Exchanges supervisor

  """
  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children =
      [
        Subscribers.LogSubscriber,
        Subscribers.HistorySubscriber,
        {PollServer, {Clients.Finnhub.FinnhubClient, tickers: Profitry.Investment.list_tickers()}}
        # {PollServer, {Clients.DummyClient, tickers: ["TSLA"], interval: 2000}}
      ]

    children = if Application.get_env(:profitry, :start_exchanges, true), do: children, else: []
    Supervisor.init(children, strategy: :one_for_one)
  end
end

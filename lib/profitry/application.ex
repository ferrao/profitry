defmodule Profitry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ProfitryWeb.Telemetry,
      # Start the Ecto repository
      Profitry.Repo,
      # {DNSCluster, query: Application.get_env(:profitry, :dns_cluster_query) || :ignore},
      # Start the PubSub system
      {Phoenix.PubSub, name: Profitry.PubSub},
      # Start Finch
      {Finch, name: Profitry.Finch},
      # Start the Endpoint (http/https)
      ProfitryWeb.Endpoint
      # Start a worker by calling: Profitry.Worker.start_link(arg)
      # {Profitry.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Profitry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProfitryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

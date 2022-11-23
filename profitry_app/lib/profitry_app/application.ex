defmodule ProfitryApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ProfitryAppWeb.Telemetry,
      # Start the Ecto repository
      ProfitryApp.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ProfitryApp.PubSub},
      # Start Finch
      {Finch, name: ProfitryApp.Finch},
      # Start the Endpoint (http/https)
      ProfitryAppWeb.Endpoint
      # Start a worker by calling: ProfitryApp.Worker.start_link(arg)
      # {ProfitryApp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProfitryApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProfitryAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Profitry.Server.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Profitry.Server.Repo,
      # Start the Telemetry supervisor
      Profitry.ServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Profitry.Server.PubSub},
      # Start the Endpoint (http/https)
      Profitry.ServerWeb.Endpoint
      # Start a worker by calling: Profitry.Server.Worker.start_link(arg)
      # {Profitry.Server.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Profitry.Server.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Profitry.ServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

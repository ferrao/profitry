# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :profitry_server,
  namespace: Profitry.Server,
  ecto_repos: [Profitry.Server.Repo]

# Configures the endpoint
config :profitry_server, Profitry.ServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EceJeqNTh1idI64KYl8mFZC62ApNgquSPMUJf08uFEwzHhTFAbsTHspS7hAbxIPG",
  render_errors: [view: Profitry.ServerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Profitry.Server.PubSub,
  live_view: [signing_salt: "+5T+XoOX"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

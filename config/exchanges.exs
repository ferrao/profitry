import Config

# config/config.exs
config :profitry, :start_exchanges, true

config :profitry, Profitry.Exchanges.Clients.Finnhub.FinnhubClient,
  url: "https://finnhub.io/api",
  version: 1,
  path: "/quote"

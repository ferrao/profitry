import Config

config :profitry, Profitry.Exchanges.Clients.Finnhub.FinnhubClient,
  url: "https://finnhub.io/api",
  version: 1,
  path: "/quote"

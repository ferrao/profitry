import Config

# Finnhub API
config :profitry_app, ProfitryApp.Exchanges.Finnhub.FinnhubClient,
  api_key: System.get_env("FINNHUB_API_KEY")

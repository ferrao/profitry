defmodule Profitry.Exchanges.Clients.Finnhub.FinnhubClient do
  @behaviour Profitry.Exchanges.PollBehaviour

  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Exchanges.Clients.Finnhub.FinnhubQuote

  @impl true
  def init() do
    [
      req:
        Req.new(
          url: endpoint(),
          params: [token: api_key()],
          retry: false
        )
    ]
  end

  @impl true
  def interval(), do: 5000

  @impl true
  def quote(ticker, opts) do
    case Req.get(opts[:req], params: [symbol: ticker]) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        body_to_quote(ticker, body)

      {:ok, %Req.Response{status: 404}} ->
        {:error, "Not found"}

      {:ok, %Req.Response{status: status}} ->
        {:error, "#{status}"}

      {:error, exception} ->
        {:error, exception.message()}
    end
  end

  @spec body_to_quote(String.t(), map()) :: {:ok, Quote.t()} | {:error, String.t()}
  defp body_to_quote(symbol, body) do
    case quote = FinnhubQuote.new(symbol, body) do
      %Quote{} -> {:ok, quote}
      {:error, _} -> {:error, "Invalid data"}
    end
  end

  @spec endpoint() :: String.t()
  def endpoint() do
    config = Application.fetch_env!(:profitry, __MODULE__)
    "#{config[:url]}/v#{config[:version]}/#{config[:path]}"
  end

  @spec api_key() :: String.t()
  defp api_key() do
    Application.fetch_env!(:profitry, __MODULE__)[:api_key]
  end
end

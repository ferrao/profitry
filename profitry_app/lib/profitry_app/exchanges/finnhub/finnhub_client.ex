defmodule ProfitryApp.Exchanges.Finnhub.FinnhubClient do
  use HTTPoison.Base
  @behaviour ProfitryApp.Exchanges.RestClient

  alias ProfitryApp.Exchanges.Finnhub.FinnhubQuote

  @impl true
  def interval(), do: 5000

  @impl true
  def process_request_headers(_headers) do
    [{"X-Finnhub-Token", Application.fetch_env!(:profitry_app, __MODULE__)[:api_key]}]
  end

  @impl true
  def process_request_url(url) do
    endpoint() <> url
  end

  @impl true
  def process_response_body(body) do
    case Jason.decode(body, keys: :atoms) do
      {:ok, body} -> body
      _ -> %{}
    end
  end

  @impl true
  def quote(symbol) do
    case get("/quote?symbol=#{symbol}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body_to_quote(symbol, body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found"}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "#{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp body_to_quote(symbol, body) do
    case quote = FinnhubQuote.new(symbol, body) do
      %ProfitryApp.Exchanges.Quote{} -> {:ok, quote}
      {:error, _} -> {:error, "Invalid data"}
    end
  end

  defp endpoint() do
    config = Application.fetch_env!(:profitry_app, __MODULE__)
    "#{config[:url]}/v#{config[:version]}"
  end
end

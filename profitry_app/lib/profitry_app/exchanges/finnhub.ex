defmodule ProfitryApp.Exchanges.Finnhub do
  use HTTPoison.Base

  # @expected_fields ~w(c d dp h l o p t)

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
    # TODO: validate @expected_fields with ecto changeset
    # to avoid creating atoms from outside world inputs
    case Jason.decode(body, keys: :atoms) do
      {:ok, body} -> body
      _ -> %{}
    end
  end

  def quote(symbol) do
    case get("/quote?symbol=#{symbol}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found"}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "#{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp endpoint do
    config = Application.fetch_env!(:profitry_app, __MODULE__)
    "#{config[:url]}/v#{config[:version]}"
  end
end

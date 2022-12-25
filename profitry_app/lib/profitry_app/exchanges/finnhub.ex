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
    body
    # DANGER: validate @expected_fields with ecto changeset
    # to avoid creating atoms from outside world inputs
    |> Jason.decode!(keys: :atoms)
  end

  def quote(symbol) do
    get!("/quote?symbol=#{symbol}").body
  end

  defp endpoint do
    config = Application.fetch_env!(:profitry_app, __MODULE__)
    "#{config[:url]}/v#{config[:version]}"
  end
end

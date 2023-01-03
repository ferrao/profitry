defmodule ProfitryApp.Exchanges do
  @moduledoc """
  The Profitry Exchanges context.
  """

  import Ecto.Query, warn: false

  alias Phoenix.PubSub
  alias ProfitryApp.Repo
  alias ProfitryApp.Investment.Position

  @doc """
  Returns the list of tickers used across all portfolios.

  ## Exanmples

    iex> list_tickers()
    ["TICKER1", "TICKER2", "TICKER3"]

  """
  def list_tickers do
    Position
    |> select([p], p.ticker)
    |> distinct(true)
    |> order_by([p], p.ticker)
    |> Repo.all()
  end

  def broadcast_quote(quote) do
    PubSub.broadcast(ProfitryApp.PubSub, "quotes", quote)
  end

  def subscribe_quotes() do
    PubSub.subscribe(ProfitryApp.PubSub, "quotes")
  end

  def unsubscribe_quotes() do
    PubSub.unsubscribe(ProfitryApp.PubSub, "quotes")
  end

  def broadcast_update(ticker) do
    PubSub.broadcast(ProfitryApp.PubSub, "updates", ticker)
  end

  def subscribe_updates() do
    PubSub.subscribe(ProfitryApp.PubSub, "updates")
  end

  def unsubscribe_updates() do
    PubSub.unsubscribe(ProfitryApp.PubSub, "updates")
  end
end

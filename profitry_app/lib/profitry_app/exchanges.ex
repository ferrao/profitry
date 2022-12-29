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

  def broadcast(quote) do
    PubSub.broadcast(ProfitryApp.PubSub, "quotes", quote)
  end

  def subscribe() do
    PubSub.subscribe(ProfitryApp.PubSub, "quotes")
  end
end

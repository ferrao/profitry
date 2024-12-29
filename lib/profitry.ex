defmodule Profitry do
  @moduledoc """
  Profitry keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Profitry.Investment
  alias Profitry.Exchanges
  alias Profitry.Exchanges.Subscribers.HistorySubscriber

  defdelegate list_tickers(), to: Investment
  defdelegate broadcast_quote(quote), to: Exchanges
  defdelegate subscribe_quotes(), to: Exchanges
  defdelegate unsubscribe_quotes(), to: Exchanges
  defdelegate get_quote(ticker), to: HistorySubscriber
  defdelegate list_quotes(ticker), to: HistorySubscriber
end

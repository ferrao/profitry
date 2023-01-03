defmodule ProfitryApp do
  @moduledoc """
  ProfitryApp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  defdelegate subscribe_quotes(), to: ProfitryApp.Exchanges
  defdelegate unsubscribe_quotes(), to: ProfitryApp.Exchanges
  defdelegate broadcast_quote(quote), to: ProfitryApp.Exchanges

  defdelegate get_quote(ticker), to: ProfitryApp.Exchanges.History
  defdelegate broadcast_update(ticker), to: ProfitryApp.Exchanges
  defdelegate subscribe_updates(), to: ProfitryApp.Exchanges
end

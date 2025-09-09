defmodule Profitry.Exchanges do
  @moduledoc """

  The Profitry Exchanges context.

  """

  @type topics :: %{
          quotes: String.t(),
          ticker_updates: String.t()
        }

  @quotes "quotes"
  @ticker_updates "update_tickers"

  alias Phoenix.PubSub
  alias Profitry.Exchanges.Schema.Quote

  @doc """

  Publishes a quote to the quotes channel.

  """
  @spec broadcast_quote(Quote.t(), String.t()) :: :ok | {:error, any()}
  def broadcast_quote(%Quote{} = quote, topic \\ @quotes) do
    PubSub.broadcast(Profitry.PubSub, topic, {:new_quote, quote})
  end

  @doc """

  Subscribes to the quotes channel.

  """
  @spec subscribe_quotes(String.t()) :: :ok | {:error, any()}
  def subscribe_quotes(topic \\ @quotes) do
    PubSub.subscribe(Profitry.PubSub, topic)
  end

  @doc """

  Unsubscribes from the quotes channel.

  """
  @spec unsubscribe_quotes(String.t()) :: :ok
  def unsubscribe_quotes(topic \\ @quotes) do
    PubSub.unsubscribe(Profitry.PubSub, topic)
  end

  @doc """

  Publishes a new ticker

  """
  @spec broadcast_ticker_update(tuple(), String.t()) :: :ok | {:error, any()}
  def broadcast_ticker_update(message, topic \\ @ticker_updates)
      when is_tuple(message) and is_atom(elem(message, 0)) do
    PubSub.broadcast(Profitry.PubSub, topic, message)
  end

  @doc """

  Subscribes to the update tickers channel.

  """
  @spec subscribe_ticker_updates(String.t()) :: :ok | {:error, any()}
  def subscribe_ticker_updates(topic \\ @ticker_updates) do
    PubSub.subscribe(Profitry.PubSub, topic)
  end
end

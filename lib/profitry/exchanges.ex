defmodule Profitry.Exchanges do
  @moduledoc """

  The Profitry Exchanges context.

  """

  alias Phoenix.PubSub
  alias Profitry.Exchanges.Schema.Quote

  @doc """

  Publishes a quote to the quotes channel.

  """
  @spec broadcast_quote(Quote.t()) :: :ok | {:error, any()}
  def broadcast_quote(%Quote{} = quote) do
    PubSub.broadcast(Profitry.PubSub, "quotes", {:new_quote, quote})
  end

  @doc """

  Subscribes to the quotes channel.

  """
  @spec subscribe_quotes() :: :ok | {:error, any()}
  def subscribe_quotes() do
    PubSub.subscribe(Profitry.PubSub, "quotes")
  end

  @doc """

  Unsubscribes from the quotes channel.

  """
  @spec unsubscribe_quotes() :: :ok
  def unsubscribe_quotes() do
    PubSub.unsubscribe(Profitry.PubSub, "quotes")
  end
end

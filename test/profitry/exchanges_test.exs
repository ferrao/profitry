defmodule Profitry.ExchangesTest do
  use ExUnit.Case, async: true

  alias Profitry.Exchanges
  alias Profitry.Exchanges.Schema.Quote

  @ticker "TSLA"
  @topic_quotes to_string(__MODULE__) <> "quotes"
  @topic_updates to_string(__MODULE__) <> "ticker_updates"

  @quote %Quote{
    exchange: "IBKR",
    ticker: @ticker,
    price: Decimal.new("666"),
    timestamp: NaiveDateTime.utc_now()
  }

  describe "exchanges" do
    test "broadcast_quote/1 sends quote to subscribers" do
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topic_quotes)

      :ok = Exchanges.broadcast_quote(@quote, @topic_quotes)

      assert_receive {:new_quote, received_quote}
      assert received_quote == @quote
    end

    test "subscribe_quotes/0 successfully subscribes to quotes channel" do
      :ok = Exchanges.subscribe_quotes(@topic_quotes)

      :ok = Phoenix.PubSub.broadcast(Profitry.PubSub, @topic_quotes, {:new_quote, @quote})

      assert_receive {:new_quote, received_quote}
      assert received_quote == @quote
    end

    test "unsubscribe_quotes/0 successfully unsubscribes from quotes channel" do
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topic_quotes)

      :ok = Exchanges.unsubscribe_quotes(@topic_quotes)
      :ok = Phoenix.PubSub.broadcast(Profitry.PubSub, "quotes", {:new_quote, @quote})

      refute_receive {:new_quote, _}
    end

    test "multiple subscribers receive the same quote" do
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topic_quotes)
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topic_quotes)

      :ok = Exchanges.broadcast_quote(@quote, @topic_quotes)

      assert_receive {:new_quote, received_quote1}
      assert_receive {:new_quote, received_quote2}
      assert received_quote1 == @quote
      assert received_quote2 == @quote
    end

    test "broadcast_ticker_update/1 sends ticker update to subscribers" do
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topic_updates)

      :ok = Exchanges.broadcast_ticker_update({:ticker_added, @ticker}, @topic_updates)

      assert_receive {:ticker_added, @ticker}
    end

    test "subscribe_ticker_updates/0 successfully subscribes to ticker updates channel" do
      :ok = Exchanges.subscribe_ticker_updates(@topic_updates)

      :ok = Phoenix.PubSub.broadcast(Profitry.PubSub, @topic_updates, {:ticker_added, @ticker})

      assert_receive {:ticker_added, @ticker}
    end
  end
end

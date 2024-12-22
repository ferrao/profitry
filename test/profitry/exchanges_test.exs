defmodule Profitry.ExchangesTest do
  use ExUnit.Case, async: true

  alias Profitry.Exchanges
  alias Profitry.Exchanges.Schema.Quote

  @quote %Quote{
    exchange: "IBKR",
    ticker: "TSLA",
    price: 666,
    timestamp: NaiveDateTime.utc_now()
  }

  describe "exchanges" do
    test "broadcast_quote/1 sends quote to subscribers" do
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      :ok = Exchanges.broadcast_quote(@quote)

      assert_receive {:new_quote, received_quote}
      assert received_quote == @quote
    end

    test "subscribe_quotes/0 successfully subscribes to quotes channel" do
      :ok = Exchanges.subscribe_quotes()

      :ok = Phoenix.PubSub.broadcast(Profitry.PubSub, "quotes", {:new_quote, @quote})

      assert_receive {:new_quote, received_quote}
      assert received_quote == @quote
    end

    test "unsubscribe_quotes/0 successfully unsubscribes from quotes channel" do
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      :ok = Exchanges.unsubscribe_quotes()
      :ok = Phoenix.PubSub.broadcast(Profitry.PubSub, "quotes", {:new_quote, @quote})

      refute_receive {:new_quote, _}
    end

    test "multiple subscribers receive the same quote" do
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      :ok = Exchanges.broadcast_quote(@quote)

      assert_receive {:new_quote, received_quote1}
      assert_receive {:new_quote, received_quote2}
      assert received_quote1 == @quote
      assert received_quote2 == @quote
    end
  end
end

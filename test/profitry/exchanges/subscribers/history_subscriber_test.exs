defmodule Profitry.Exchanges.Subscribers.HistorySubscriberTest do
  use ExUnit.Case, async: true

  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Exchanges.Subscribers.HistorySubscriber

  # override topics to allow for async tests
  @topics %{
    quotes: to_string(__MODULE__) <> "_quotes",
    ticker_updates: to_string(__MODULE__) <> "_ticker_updates"
  }

  @quote1 %Quote{
    exchange: "IBKR",
    ticker: "TSLA",
    price: Decimal.new("231.5"),
    timestamp: ~N[2023-01-01 16:30:00]
  }

  @quote2 %Quote{
    exchange: "IBKR",
    ticker: "SOFI",
    price: Decimal.new("16"),
    timestamp: ~N[2024-01-01 16:30:00]
  }

  @quote3 %Quote{
    @quote1
    | price: Decimal.add(@quote1.price, 1),
      timestamp: NaiveDateTime.add(@quote1.timestamp, 1, :day)
  }

  @quote4 %Quote{
    @quote2
    | price: Decimal.add(@quote2.price, 1),
      timestamp: NaiveDateTime.add(@quote2.timestamp, 1, :day)
  }

  @quote5 %Quote{
    @quote3
    | price: Decimal.add(@quote3.price, 1),
      timestamp: NaiveDateTime.add(@quote3.timestamp, 1, :day)
  }

  @quote6 %Quote{
    @quote4
    | price: Decimal.add(@quote4.price, 1),
      timestamp: NaiveDateTime.add(@quote4.timestamp, 1, :day)
  }

  describe "history subscriber" do
    test "state is initialized and preserved" do
      backlog_size = 3

      start_supervised!(
        {HistorySubscriber, backlog_size: backlog_size, topics: @topics, name: __MODULE__}
      )

      state = :sys.get_state(__MODULE__)

      assert state.backlog_size === backlog_size
      assert state.quotes === %{}
    end

    test "keeps a history of recent quotes for each ticker" do
      backlog_size = 2

      start_supervised!(
        {HistorySubscriber, backlog_size: backlog_size, topics: @topics, name: __MODULE__}
      )

      # Give HistorySubscriber time to subscribe to pubsub
      Process.sleep(100)

      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote1})
      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote2})
      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote3})
      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote4})
      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote5})
      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote6})

      # Give HistorySubscriber time to receive the messages
      Process.sleep(100)

      tsla_quotes = HistorySubscriber.list_quotes(__MODULE__, "TSLA")
      sofi_quotes = HistorySubscriber.list_quotes(__MODULE__, "SOFI")

      assert Enum.count(tsla_quotes) === backlog_size
      assert Enum.count(sofi_quotes) === backlog_size

      assert tsla_quotes === [@quote5, @quote3]
      assert sofi_quotes === [@quote6, @quote4]
    end

    test "gets the most recent quote for a ticker" do
      backlog_size = 2

      start_supervised!(
        {HistorySubscriber, backlog_size: backlog_size, topics: @topics, name: __MODULE__}
      )

      # Give HistorySubscriber time to subscribe to pubsub
      Process.sleep(100)

      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote1})
      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote3})
      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote5})

      # Give HistorySubscriber time to receive the messages
      Process.sleep(100)

      assert HistorySubscriber.get_quote(__MODULE__, "TSLA") === @quote5
    end

    test "does not find quotes for non existing ticker" do
      start_supervised!({HistorySubscriber, topics: @topics, name: __MODULE__})

      assert HistorySubscriber.list_quotes(__MODULE__, "TSLA") === []
      assert HistorySubscriber.get_quote(__MODULE__, "TSLA") === nil
    end
  end

  describe "event handling" do
    test "migrates history when a ticker changes" do
      start_supervised!({HistorySubscriber, topics: @topics, name: __MODULE__})
      # Allow time for the subscriber to start and subscribe to the PubSub topic.
      Process.sleep(100)

      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.quotes, {:new_quote, @quote1})
      # Allow time for the subscriber to process the async :new_quote event.
      Process.sleep(100)

      assert HistorySubscriber.list_quotes(__MODULE__, "TSLA") === [@quote1]
      assert HistorySubscriber.list_quotes(__MODULE__, "NEW") === []

      Phoenix.PubSub.broadcast(
        Profitry.PubSub,
        @topics.ticker_updates,
        {:ticker_changed, "TSLA", "NEW"}
      )

      # Allow time for the subscriber to process the async :ticker_changed event.
      Process.sleep(100)

      assert HistorySubscriber.list_quotes(__MODULE__, "TSLA") === [@quote1]
      assert HistorySubscriber.list_quotes(__MODULE__, "NEW") === [@quote1]
    end

    test "restarts when the ticker configuration changes" do
      {:ok, pid} = start_supervised({HistorySubscriber, topics: @topics, name: __MODULE__})
      monitor = Process.monitor(pid)

      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.ticker_updates, {:ticker_config_changed})

      assert_receive {:DOWN, ^monitor, :process, _, _}, 100
    end
  end
end

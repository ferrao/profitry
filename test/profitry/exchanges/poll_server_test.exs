defmodule Profitry.Exchanges.PollServerTest do
  use ExUnit.Case, async: true

  alias Profitry.Exchanges.Clients.DummyClient
  alias Profitry.Exchanges.PollServer

  @message_timeout 2000

  # override default topics to allow for async tests
  @topics %{
    quotes: to_string(__MODULE__) <> "_quotes",
    ticker_updates: to_string(__MODULE__) <> "_ticker_updates"
  }

  describe "poll server" do
    test "client options are initialized and preserved" do
      client_opts = DummyClient.init()

      start_supervised!(
        {PollServer,
         {DummyClient, tickers: ["TSLA"], interval: 1000, topics: @topics, name: __MODULE__}}
      )

      state = :sys.get_state(__MODULE__)

      {:noreply, new_state} = PollServer.handle_info(:tick, state)

      assert new_state.client_opts === client_opts
    end

    test "quotes arrive within configured interval" do
      interval = 200
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topics.quotes)

      start_supervised!(
        {PollServer,
         {DummyClient, tickers: ["TSLA"], interval: interval, topics: @topics, name: __MODULE__}}
      )

      refute_receive {:neq_qoote}, interval - 50
      assert_receive {:new_quote, _received_quote}, interval + 50
    end

    test "loops over the quotes" do
      tickers = ["TSLA", "SOFI", "HOOD"]
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topics.quotes)

      start_supervised!(
        {PollServer,
         {DummyClient, tickers: tickers, interval: 0, topics: @topics, name: __MODULE__}}
      )

      for ticker <- tickers |> Enum.concat(tickers) |> Enum.concat(tickers) do
        assert_receive {:new_quote, received_quote}, @message_timeout
        assert(received_quote.ticker === ticker)
      end
    end

    test "adds a new ticker to the ticker list" do
      ticker = "TSLA"
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topics.quotes)

      start_supervised!(
        {PollServer, {DummyClient, tickers: [], interval: 0, topics: @topics, name: __MODULE__}}
      )

      refute_receive {:neq_qoote}, @message_timeout

      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.ticker_updates, ticker)

      assert_receive {:new_quote, received_quote}, @message_timeout
      assert(received_quote.ticker === ticker)
    end

    test "does not add the same ticker to the ticker list multiple times" do
      tickers = ["TSLA"]
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, @topics.ticker_updates)

      start_supervised!(
        {PollServer,
         {DummyClient, tickers: tickers, interval: 0, topics: @topics, name: __MODULE__}}
      )

      Phoenix.PubSub.broadcast(Profitry.PubSub, "update_tickers", hd(tickers))
      Phoenix.PubSub.broadcast(Profitry.PubSub, "update_tickers", hd(tickers))
      Phoenix.PubSub.broadcast(Profitry.PubSub, "update_tickers", hd(tickers))

      # Give PollServer time to receive the messages
      Process.sleep(100)

      state = :sys.get_state(__MODULE__)
      assert tickers === state.tickers
    end
  end

  describe "event handling" do
    test "updates the ticker list when a ticker changes" do
      tickers = ["OLD", "AAPL"]

      start_supervised!(
        {PollServer,
         {DummyClient, tickers: tickers, interval: 0, topics: @topics, name: __MODULE__}}
      )

      Phoenix.PubSub.broadcast(
        Profitry.PubSub,
        @topics.ticker_updates,
        {:ticker_changed, "OLD", "NEW"}
      )

      # Give PollServer time to receive the messages
      Process.sleep(100)

      state = :sys.get_state(__MODULE__)
      assert state.tickers === ["NEW", "AAPL"]
    end

    test "restarts when the ticker configuration changes" do
      {:ok, pid} =
        start_supervised({PollServer, {DummyClient, name: __MODULE__, topics: @topics}})

      monitor = Process.monitor(pid)

      Phoenix.PubSub.broadcast(Profitry.PubSub, @topics.ticker_updates, {:ticker_config_changed})

      assert_receive {:DOWN, ^monitor, :process, _, _}, 100
    end
  end
end

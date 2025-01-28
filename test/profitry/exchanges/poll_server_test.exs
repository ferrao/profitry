defmodule Profitry.Exchanges.PollServerTest do
  # FIXME: Not running async due to genserver name and pubsub topic being shared between tests
  use ExUnit.Case, async: false

  alias Profitry.Exchanges.Clients.DummyClient
  alias Profitry.Exchanges.PollServer

  @message_timeout 2000

  describe "poll server" do
    test "client options are initialized and preserved" do
      client_opts = DummyClient.init()

      server = start_supervised!({PollServer, {DummyClient, tickers: ["TSLA"], interval: 1000}})

      state = :sys.get_state(server)

      {:noreply, new_state} = PollServer.handle_info(:tick, state)

      assert new_state.client_opts === client_opts
    end

    test "quotes arrive within configured interval" do
      interval = 200
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      start_supervised!({PollServer, {DummyClient, tickers: ["TSLA"], interval: interval}})

      refute_receive {:neq_qoote}, interval - 50
      assert_receive {:new_quote, _received_quote}, interval + 50
    end

    test "loops over the quotes" do
      tickers = ["TSLA", "SOFI", "HOOD"]
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      start_supervised!({PollServer, {DummyClient, tickers: tickers, interval: 0}})

      for ticker <- tickers |> Enum.concat(tickers) |> Enum.concat(tickers) do
        assert_receive {:new_quote, received_quote}, @message_timeout
        assert(received_quote.ticker === ticker)
      end
    end

    test "adds a new ticker to the ticker list" do
      ticker = "TSLA"
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      start_supervised!({PollServer, {DummyClient, tickers: [], interval: 0}})

      refute_receive {:neq_qoote}, @message_timeout

      Phoenix.PubSub.broadcast(Profitry.PubSub, "update_tickers", ticker)

      assert_receive {:new_quote, received_quote}, @message_timeout
      assert(received_quote.ticker === ticker)
    end

    test "does not add the same ticker to the ticker list multiple times" do
      tickers = ["TSLA"]
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "update_tickers")

      server = start_supervised!({PollServer, {DummyClient, tickers: tickers, interval: 0}})
      Phoenix.PubSub.broadcast(Profitry.PubSub, "update_tickers", hd(tickers))
      Phoenix.PubSub.broadcast(Profitry.PubSub, "update_tickers", hd(tickers))
      Phoenix.PubSub.broadcast(Profitry.PubSub, "update_tickers", hd(tickers))

      # Give PollServer time to receive the messages
      Process.sleep(100)

      state = :sys.get_state(server)
      assert tickers === state.tickers
    end
  end
end

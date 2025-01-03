defmodule Profitry.Exchanges.PollServerTest do
  # Not running async due to genserver name and pubsub topic being shared between tests
  use ExUnit.Case

  alias Profitry.Exchanges.Clients.DummyClient
  alias Profitry.Exchanges.PollServer

  @message_timeout 2000

  describe "poll server" do
    test "client options are initialized and preserved" do
      client_opts = DummyClient.init()
      {:ok, server} = PollServer.start_link(DummyClient, tickers: ["TSLA"], interval: 1000)
      state = :sys.get_state(server)

      {:noreply, new_state} = PollServer.handle_info(:tick, state)

      assert new_state.client_opts === client_opts
    end

    test "quotes arrive within configured interval" do
      interval = 200
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      {:ok, server} = PollServer.start_link(DummyClient, tickers: ["TSLA"], interval: interval)

      refute_receive {:neq_qoote}, interval - 50
      assert_receive {:new_quote, _received_quote}, interval + 50

      Process.exit(server, :normal)
    end

    test "loops over the quotes" do
      tickers = ["TSLA", "SOFI", "HOOD"]
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      {:ok, server} = PollServer.start_link(DummyClient, tickers: tickers, interval: 0)

      for ticker <- tickers |> Enum.concat(tickers) |> Enum.concat(tickers) do
        assert_receive {:new_quote, received_quote}, @message_timeout
        assert(received_quote.ticker === ticker)
      end

      Process.exit(server, :normal)
    end

    test "can be supervised" do
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      {:ok, server} =
        Supervisor.start_link(
          [
            {PollServer, {DummyClient, tickers: ["TSLA"], interval: 0}}
          ],
          strategy: :one_for_one
        )

      assert_receive {:new_quote, _received_quote}, @message_timeout

      Process.exit(server, :normal)
    end
  end
end

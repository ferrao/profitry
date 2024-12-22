defmodule Profitry.Exchanges.PollServerTest do
  use ExUnit.Case

  alias Profitry.Exchanges.Clients.DummyClient
  alias Profitry.Exchanges.PollServer

  @message_timeout 2000

  describe "poll server" do
    test "quotes arrive within configured interval" do
      interval = 1000
      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      {:ok, server} = PollServer.start_link(DummyClient, tickers: ["TSLA"], interval: interval)

      refute_receive {:neq_qoote}, interval - 100
      assert_receive {:new_quote, _received_quote}, interval + 100

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
            {PollServer, {DummyClient, tickers: ["TSLA"], interval: 1}}
          ],
          strategy: :one_for_one
        )

      assert_receive {:new_quote, _received_quote}, @message_timeout

      Process.exit(server, :normal)
    end
  end
end

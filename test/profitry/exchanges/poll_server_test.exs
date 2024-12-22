defmodule Profitry.Exchanges.PollServerTest do
  use ExUnit.Case, async: true

  alias Profitry.Exchanges.Clients.DummyClient
  alias Profitry.Exchanges.PollServer

  describe "poll server" do
    test "loops over the quotes" do
      tickers = ["TSLA", "SOFI", "HOOD"]
      {:ok, server} = PollServer.start(DummyClient, tickers)

      :ok = Phoenix.PubSub.subscribe(Profitry.PubSub, "quotes")

      for ticker <- tickers |> Enum.concat(tickers) |> Enum.concat(tickers) do
        send(server, :tick)

        assert_receive {:new_quote, received_quote}, DummyClient.interval() - 100
        assert(received_quote.ticker === ticker)
      end
    end
  end
end

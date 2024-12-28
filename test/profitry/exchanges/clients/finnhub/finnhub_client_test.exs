defmodule Profitry.Exchanges.Clients.Finnhub.FinnhubClientTest do
  use ExUnit.Case, async: true

  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Exchanges.Clients.Finnhub.FinnhubClient

  @mock_response %{
    status: 200,
    body: %{
      "c" => 148.97,
      "h" => 149.77,
      "l" => 147.85,
      "o" => 148.97,
      "pc" => 149.84,
      "t" => 1_708_718_399
    }
  }

  @mock_quote %Quote{
    exchange: "FINNHUB",
    ticker: "AAPL",
    price: Decimal.new("148.97"),
    timestamp: ~U[2024-02-23 19:59:59Z]
  }

  defp stub_req(_) do
    %{req: Req.new(retry: false, plug: {Req.Test, __MODULE__})}
  end

  describe "finnhub client" do
    setup [:stub_req]

    test "init/0 returns a req request" do
      options = FinnhubClient.init()

      assert %Req.Request{} = options[:req]
    end

    test "interval/0 returns an integer" do
      assert is_integer(FinnhubClient.interval())
    end

    test "quote/2 returns quote when successful", %{req: req} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.json(conn, @mock_response.body)
      end)

      {:ok, quote} = FinnhubClient.quote("AAPL", req: req)
      assert quote === @mock_quote
    end

    test "quote/2 returns not found error on 404", %{req: req} do
      Req.Test.stub(__MODULE__, fn conn ->
        Plug.Conn.send_resp(conn, 404, "")
      end)

      assert {:error, "Not found"} === FinnhubClient.quote("AAPL", req: req)
    end

    test "quote/2 returns unauthorized error if not authenticated", %{req: req} do
      Req.Test.stub(__MODULE__, fn conn ->
        Plug.Conn.send_resp(conn, 401, "Unauthorized")
      end)

      assert {:error, "401 Unauthorized"} === FinnhubClient.quote("AAPL", req: req)
    end

    test "quote/2 returns timeout error on network timeout", %{req: req} do
      Req.Test.stub(__MODULE__, fn conn ->
        Req.Test.transport_error(conn, :timeout)
      end)

      assert {:error, "timeout"} === FinnhubClient.quote("AAPL", req: req)
    end

    test "quote/2 returns appropriate errors ", %{req: req} do
      Req.Test.stub(__MODULE__, fn conn ->
        Plug.Conn.send_resp(conn, 500, "Server Failure")
      end)

      assert {:error, "500 Server Failure"} === FinnhubClient.quote("AAPL", req: req)
    end
  end
end

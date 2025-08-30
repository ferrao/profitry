defmodule Profitry.FileTest do
  use Profitry.DataCase, async: false

  import Profitry.InvestmentFixtures
  import Profitry.ParsersFixtures

  alias Profitry.Import.File
  alias Profitry.Investment.Schema.{Portfolio, Position, Order}

  @order %{
    ticker: "TSLA",
    type: "buy",
    instrument: "option",
    quantity: "1.3",
    price: "132.3",
    fees: "1.2",
    inserted_at: "2024-01-01 12:00:07",
    option: %{type: "call", strike: "50", expiration: "2024-02-01"}
  }

  describe "import" do
    test "processes file" do
      ticker_change_fixture(%{ticker: "TSLA", original_ticker: "XXXX"})
      portfolio = portfolio_fixture()

      orders =
        File.process(portfolio.id, "test/support/csv/ibkr.csv")

      assert is_list(orders)

      assert Enum.map(orders, fn order -> order.position.ticker end) === [
               "CLOV",
               "TSLA",
               "SOFI",
               "SOFI",
               "TSLA",
               "TSLA"
             ]
    end

    test "gets portfolio with positions" do
      portfolio = portfolio_fixture()
      position_fixture(portfolio, %{ticker: "TSLA"})
      position_fixture(portfolio, %{ticker: "IBM"})

      portfolio = File.portfolio_with_positions(portfolio.id)
      [position1 | [position2]] = portfolio.positions

      assert %Portfolio{} = portfolio
      assert %Position{} = position1
      assert %Position{} = position2
      assert position1.ticker === "TSLA"
      assert position2.ticker === "IBM"
    end

    test "gets trade tickers" do
      tickers = trades_fixture() |> File.trade_tickers()

      assert tickers === ["CLOV", "XXXX", "SOFI", "TSLA"]
      assert [] === File.trade_tickers([])
    end

    test "creates order" do
      ticker_change = ticker_change_fixture()
      portfolio = portfolio_fixture()
      position = position_fixture(portfolio, %{ticker: ticker_change.original_ticker})

      {:ok, order} =
        File.insert_order([position, %{position | ticker: "CLOV"}], %{
          @order
          | ticker: ticker_change.ticker
        })

      assert %Order{} = order
    end

    test "creates positions" do
      ticker_change = ticker_change_fixture()
      portfolio = portfolio_fixture()
      portfolio = Repo.preload(portfolio, :positions)

      [position1 | [position2]] =
        File.create_positions(portfolio, [ticker_change.original_ticker, "CLOV"])

      assert %Position{} = position1
      assert %Position{} = position2
      assert position1.ticker === ticker_change.ticker
      assert position2.ticker === "CLOV"
    end

    test "creates only new positions" do
      ticker_change = ticker_change_fixture()
      portfolio = portfolio_fixture()
      position_fixture(portfolio, %{ticker: "TSLA"})
      position_fixture(portfolio, %{ticker: "IBM"})
      position_fixture(portfolio, %{ticker: ticker_change.ticker})
      portfolio = Repo.preload(portfolio, :positions)

      [position] =
        File.create_positions(portfolio, ["TSLA", "CLOV", ticker_change.original_ticker])

      assert %Position{} = position
      assert position.ticker === "CLOV"
    end
  end
end

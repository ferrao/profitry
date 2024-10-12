defmodule Profitry.FileTest do
  use Profitry.DataCase, async: true

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
    inserted_at: "2024-01-01 12:00:07",
    option: %{type: "call", strike: "50", expiration: "2024-02-01"}
  }

  describe "import" do
    test "processes file" do
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

      assert tickers === ["CLOV", "TSLA", "SOFI"]
      assert [] === File.trade_tickers([])
    end

    test "creates order" do
      {_portfolio, position} = position_fixture()
      {:ok, order} = File.insert_order([position, %{position | ticker: "CLOV"}], @order)

      assert %Order{} = order
    end

    test "creates positions" do
      portfolio = portfolio_fixture()
      portfolio = Repo.preload(portfolio, :positions)

      [position1 | [position2]] = File.create_positions(portfolio, ["TSLA", "CLOV"])

      assert %Position{} = position1
      assert %Position{} = position2
      assert position1.ticker === "TSLA"
      assert position2.ticker === "CLOV"
    end

    test "creates only new positions" do
      portfolio = portfolio_fixture()
      position_fixture(portfolio, %{ticker: "TSLA"})
      position_fixture(portfolio, %{ticker: "IBM"})
      portfolio = Repo.preload(portfolio, :positions)

      [position] = File.create_positions(portfolio, ["TSLA", "CLOV"])

      assert %Position{} = position
      assert position.ticker === "CLOV"
    end
  end
end

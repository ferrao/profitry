defmodule Profitry.Investment.PortfoliosTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Schema.{PositionReport, Portfolio, Position}

  describe "investment" do
    test "create_portfolio/1 with valid data creates portfolio" do
      attrs = %{broker: "eToro", description: "Lame portfolio"}

      assert {:ok, %Portfolio{} = portfolio} = Investment.create_portfolio(attrs)
      assert portfolio.broker === String.upcase(attrs.broker)
      assert portfolio.description === attrs.description
      assert portfolio === Repo.get!(Portfolio, portfolio.id)
    end

    test "create_portfolio/1 with invalid data creates an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(%{})
    end

    test "list_porfolios/0 returns existing portfolios" do
      portfolio = portfolio_fixture()

      assert Investment.list_portfolios() === [portfolio]
    end

    test "get_portfolio!/1 returns existing portfolio" do
      portfolio = portfolio_fixture()

      assert Investment.get_portfolio!(portfolio.id) === portfolio
    end

    test "get_portfolio/1 returns nil for invalid portfolio id" do
      assert_raise Ecto.NoResultsError, fn -> Investment.get_portfolio!(9999) end
    end

    test "update_portfolio/2 with valid data updates portfolio" do
      portfolio = portfolio_fixture()
      attrs = %{broker: "eToro", description: "Lame portfolio"}

      assert {:ok, %Portfolio{} = portfolio} = Investment.update_portfolio(portfolio, attrs)
      assert portfolio.broker === String.upcase(attrs.broker)
      assert portfolio.description === attrs.description
      assert portfolio === Repo.get!(Portfolio, portfolio.id)
    end

    test "update_portfolio/2 with invalid data creates an error changeset" do
      portfolio = portfolio_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.update_portfolio(portfolio, %{broker: nil})

      assert {:error, %Ecto.Changeset{}} =
               Investment.update_portfolio(portfolio, %{description: nil})

      assert portfolio === Repo.get!(Portfolio, portfolio.id)
    end

    test "change_portfolio/1 returns a portfolio changeset" do
      portfolio = portfolio_fixture()

      assert %Ecto.Changeset{} = Investment.change_portfolio(portfolio)
    end

    test "delete_portfolio/1 deletes portfolio" do
      portfolio = portfolio_fixture()

      assert {:ok, %Portfolio{}} = Investment.delete_portfolio(portfolio)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Portfolio, portfolio.id) end
    end

    test "delete_portfolio/1 creates an error changeset for a portfolio with positions" do
      {portfolio, _position} = position_fixture()

      assert {:error, %Ecto.Changeset{} = changeset} = Investment.delete_portfolio(portfolio)
      assert ["Portfolio contains positions"] = errors_on(changeset).positions
      assert portfolio === Repo.get!(Portfolio, portfolio.id)
    end

    test "list_reports!/2 lists reports for a portfolio" do
      {portfolio, _position, _order} = option_fixture()

      reports = Investment.list_reports!(portfolio.id)

      assert [%PositionReport{}] = reports
    end

    test "list_reports!/2 filters list of reports for a portfolio" do
      {portfolio, _position, _order} = option_fixture()

      reports_tsla = Investment.list_reports!(portfolio.id, "ts")
      reports_sofi = Investment.list_reports!(portfolio.id, "so")

      assert [%PositionReport{}] = reports_tsla
      assert [] = reports_sofi
    end

    test "list_reports!/2 uses most recent ticker for a portfolio" do
      {portfolio, position, _order} = option_fixture()
      ticker_change = ticker_change_fixture()

      Repo.insert(%Position{
        ticker: ticker_change.original_ticker,
        portfolio: portfolio
      })

      [report2, report1] = Investment.list_reports!(portfolio.id)
      assert report1.ticker === position.ticker
      assert report2.ticker === ticker_change.ticker
    end

    test "list_tickers/0 lists most recent tickers for all portfolios" do
      ticker_change_fixture(%{ticker: "PTRAQ", original_ticker: "PTRA"})
      position_fixture()
      portfolio = portfolio_fixture(%{broker: "HOOD", description: "RobinHood"})
      position_fixture(portfolio, %{ticker: "SOFI"})
      position_fixture(portfolio, %{ticker: "PTRA"})

      assert Investment.list_tickers() === ["PTRAQ", "SOFI", "TSLA"]
    end
  end
end

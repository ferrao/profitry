defmodule Profitry.Investment.PortfoliosTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Portfolios
  alias Profitry.Investment.Schema.{PositionReport, Portfolio}

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

      assert %Ecto.Changeset{} = Portfolios.change_portfolio(portfolio)
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

    test "list_reports!/1 lists reports for a portfolio" do
      {portfolio, _position, _order} = option_fixture()

      reports = Portfolios.list_reports!(portfolio.id)

      assert [%PositionReport{}] = reports
    end
  end
end

defmodule ProfitryApp.Investment.PortfolioTest do
  use ProfitryApp.DataCase

  alias ProfitryApp.Investment

  describe "portfolios" do
    alias ProfitryApp.Investment.Portfolio

    import ProfitryApp.InvestmentFixtures

    @invalid_attrs %{name: nil, tikr: nil}

    test "list_portfolios/0 returns all portfolios" do
      portfolio = portfolio_fixture()
      assert Investment.list_portfolios() == [portfolio]
    end

    test "get_portfolio!/1 returns the portfolio with given id" do
      portfolio = portfolio_fixture()
      assert Investment.get_portfolio!(portfolio.id) == portfolio
    end

    test "create_portfolio/1 with valid data creates a portfolio" do
      valid_attrs = %{name: "some name", tikr: "some tikr"}

      assert {:ok, %Portfolio{} = portfolio} = Investment.create_portfolio(valid_attrs)
      assert portfolio.name == "some name"
      assert portfolio.tikr == "some tikr"
    end

    test "create_portfolio/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(@invalid_attrs)
    end

    test "update_portfolio/2 with valid data updates the portfolio" do
      portfolio = portfolio_fixture()
      update_attrs = %{name: "some updated name", tikr: "some updated tikr"}

      assert {:ok, %Portfolio{} = portfolio} =
               Investment.update_portfolio(portfolio, update_attrs)

      assert portfolio.name == "some updated name"
      assert portfolio.tikr == "some updated tikr"
    end

    test "update_portfolio/2 with invalid data returns error changeset" do
      portfolio = portfolio_fixture()
      assert {:error, %Ecto.Changeset{}} = Investment.update_portfolio(portfolio, @invalid_attrs)
      assert portfolio == Investment.get_portfolio!(portfolio.id)
    end

    test "delete_portfolio/1 deletes the portfolio" do
      portfolio = portfolio_fixture()
      assert {:ok, %Portfolio{}} = Investment.delete_portfolio(portfolio)
      assert_raise Ecto.NoResultsError, fn -> Investment.get_portfolio!(portfolio.id) end
    end

    test "change_portfolio/1 returns a portfolio changeset" do
      portfolio = portfolio_fixture()
      assert %Ecto.Changeset{} = Investment.change_portfolio(portfolio)
    end
  end
end

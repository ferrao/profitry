defmodule ProfitryApp.CoreTest do
  use ProfitryApp.DataCase

  alias ProfitryApp.Core

  describe "portfolios" do
    alias ProfitryApp.Core.Portfolio

    import ProfitryApp.CoreFixtures

    @invalid_attrs %{name: nil, tikr: nil}

    test "list_portfolios/0 returns all portfolios" do
      portfolio = portfolio_fixture()
      assert Core.list_portfolios() == [portfolio]
    end

    test "get_portfolio!/1 returns the portfolio with given id" do
      portfolio = portfolio_fixture()
      assert Core.get_portfolio!(portfolio.id) == portfolio
    end

    test "create_portfolio/1 with valid data creates a portfolio" do
      valid_attrs = %{name: "some name", tikr: "some tikr"}

      assert {:ok, %Portfolio{} = portfolio} = Core.create_portfolio(valid_attrs)
      assert portfolio.name == "some name"
      assert portfolio.tikr == "some tikr"
    end

    test "create_portfolio/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_portfolio(@invalid_attrs)
    end

    test "update_portfolio/2 with valid data updates the portfolio" do
      portfolio = portfolio_fixture()
      update_attrs = %{name: "some updated name", tikr: "some updated tikr"}

      assert {:ok, %Portfolio{} = portfolio} = Core.update_portfolio(portfolio, update_attrs)
      assert portfolio.name == "some updated name"
      assert portfolio.tikr == "some updated tikr"
    end

    test "update_portfolio/2 with invalid data returns error changeset" do
      portfolio = portfolio_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_portfolio(portfolio, @invalid_attrs)
      assert portfolio == Core.get_portfolio!(portfolio.id)
    end

    test "delete_portfolio/1 deletes the portfolio" do
      portfolio = portfolio_fixture()
      assert {:ok, %Portfolio{}} = Core.delete_portfolio(portfolio)
      assert_raise Ecto.NoResultsError, fn -> Core.get_portfolio!(portfolio.id) end
    end

    test "change_portfolio/1 returns a portfolio changeset" do
      portfolio = portfolio_fixture()
      assert %Ecto.Changeset{} = Core.change_portfolio(portfolio)
    end
  end
end

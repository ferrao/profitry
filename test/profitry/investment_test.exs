defmodule Profitry.InvestmentTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Schema.Portfolio

  describe "investment" do
    test "create_portfolio/1 with valid data creates portfolio" do
      attrs = %{broker: "eToro", description: "Lame portfolio"}

      assert {:ok, %Portfolio{} = portfolio} = Investment.create_portfolio(attrs)
      assert portfolio.broker == String.upcase(attrs.broker)
      assert portfolio.description == attrs.description
    end

    test "create_portfolio/1 with invalid data creates an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(%{})
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(%{broker: "eToro"})
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(%{description: "You wish"})
    end

    test "list_porfolios/0 returns existing portfolios" do
      portfolio = portfolio_fixture()

      assert Investment.list_portfolios() == [portfolio]
    end

    test "get_portfolio/1 returns existing portfolio" do
      portfolio = portfolio_fixture()

      assert Investment.get_portfolio(portfolio.id) == portfolio
    end

    test "get_portfolio/1 returns nil for invalid portfolio id" do
      assert Investment.get_portfolio(9999) == nil
    end

    test "update_portfolio/2 with valid data updates portfolio" do
      portfolio = portfolio_fixture()
      attrs = %{broker: "eToro", description: "Lame portfolio"}

      assert {:ok, %Portfolio{} = portfolio} = Investment.update_portfolio(portfolio, attrs)
      assert portfolio.broker == String.upcase(attrs.broker)
      assert portfolio.description == attrs.description
    end

    test "update_portfolio/2 with invalid data creates an error changeset" do
      portfolio = portfolio_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.update_portfolio(portfolio, %{broker: nil})

      assert {:error, %Ecto.Changeset{}} =
               Investment.update_portfolio(portfolio, %{description: nil})

      assert portfolio == Repo.get!(Portfolio, portfolio.id)
    end
  end
end

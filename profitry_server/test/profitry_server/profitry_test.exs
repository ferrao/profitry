defmodule Profitry.Server.ProfitryTest do
  use Profitry.Server.DataCase

  alias Profitry.Server.Profitry

  describe "portfolios" do
    alias Profitry.Server.Profitry.Portfolio

    @valid_attrs %{description: "some description", name: "some name"}
    @update_attrs %{description: "some updated description", name: "some updated name"}
    @invalid_attrs %{description: nil, name: nil}

    def portfolio_fixture(attrs \\ %{}) do
      {:ok, portfolio} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Profitry.create_portfolio()

      portfolio
    end

    test "list_portfolios/0 returns all portfolios" do
      portfolio = portfolio_fixture()
      assert Profitry.list_portfolios() == [portfolio]
    end

    test "get_portfolio!/1 returns the portfolio with given id" do
      portfolio = portfolio_fixture()
      assert Profitry.get_portfolio!(portfolio.id) == portfolio
    end

    test "create_portfolio/1 with valid data creates a portfolio" do
      assert {:ok, %Portfolio{} = portfolio} = Profitry.create_portfolio(@valid_attrs)
      assert portfolio.description == "some description"
      assert portfolio.name == "some name"
    end

    test "create_portfolio/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profitry.create_portfolio(@invalid_attrs)
    end

    test "update_portfolio/2 with valid data updates the portfolio" do
      portfolio = portfolio_fixture()
      assert {:ok, %Portfolio{} = portfolio} = Profitry.update_portfolio(portfolio, @update_attrs)
      assert portfolio.description == "some updated description"
      assert portfolio.name == "some updated name"
    end

    test "update_portfolio/2 with invalid data returns error changeset" do
      portfolio = portfolio_fixture()
      assert {:error, %Ecto.Changeset{}} = Profitry.update_portfolio(portfolio, @invalid_attrs)
      assert portfolio == Profitry.get_portfolio!(portfolio.id)
    end

    test "delete_portfolio/1 deletes the portfolio" do
      portfolio = portfolio_fixture()
      assert {:ok, %Portfolio{}} = Profitry.delete_portfolio(portfolio)
      assert_raise Ecto.NoResultsError, fn -> Profitry.get_portfolio!(portfolio.id) end
    end

    test "change_portfolio/1 returns a portfolio changeset" do
      portfolio = portfolio_fixture()
      assert %Ecto.Changeset{} = Profitry.change_portfolio(portfolio)
    end
  end
end

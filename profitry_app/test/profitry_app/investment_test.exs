defmodule ProfitryApp.Investment.InvestmentTest do
  alias ProfitryApp.Investment.{Portfolio, Position}
  use ProfitryApp.DataCase, async: true

  import ProfitryApp.{InvestmentFixtures, AccountsFixtures}

  alias ProfitryApp.Investment

  describe "investment" do
    test "list_porfolios/0 returns empty list" do
      assert Investment.list_portfolios() == []
    end

    test "list_porfolios/0 returns existing portfolios" do
      {_user, portfolio} = portfolio_fixture()

      assert Investment.list_portfolios() |> Repo.preload(:user) == [portfolio]
    end

    test "list_portfolios/1 returns empty list for a user" do
      user = user_fixture()

      assert Investment.list_portfolios(user) == []
    end

    test "list_porfolios/1 returns portfolios for a user" do
      {user, portfolio} = portfolio_fixture()

      assert Investment.list_portfolios(user) |> Repo.preload(:user) == [portfolio]
    end

    test "get_portfolio!/1 returns error for invalid portfolio" do
      assert_raise(Ecto.NoResultsError, fn -> Investment.get_portfolio!(666) end)
    end

    test "get_portfolio!/1 returns a single portfolio" do
      {_user, portfolio} = portfolio_fixture()

      assert Investment.get_portfolio!(portfolio.id) |> Repo.preload(:user) == portfolio
    end

    test "get_portfolio/2 returns nil for invalid portfolio" do
      user = user_fixture()

      assert Investment.get_portfolio(user, 666) == nil
    end

    test "get_portfolio/2 returns a single portfolio" do
      {user, portfolio} = portfolio_fixture()

      assert Investment.get_portfolio(user, portfolio.id) |> Repo.preload(:user) == portfolio
    end

    test "create_porfolio/2 with valid data creates portfolio" do
      user = user_fixture()
      valid_attrs = %{name: "eToro", ticker: "ETORO"}

      assert {:ok, %Portfolio{} = portfolio} = Investment.create_portfolio(user, valid_attrs)
      assert portfolio.user_id == user.id
      assert portfolio.name == valid_attrs.name
      assert portfolio.ticker == valid_attrs.ticker
    end

    test "create_porfolio/2 with invalid data creates an error changeset" do
      user = user_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(user, %{})
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(user, %{name: "eToro"})
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(user, %{ticker: "ETORO"})
    end

    test "update_porfolio/2 with valid data updates portfolio" do
      {_user, portfolio} = portfolio_fixture()
      valid_attrs = %{name: "eToro", ticker: "ETORO"}

      assert {:ok, %Portfolio{} = portfolio} = Investment.update_portfolio(portfolio, valid_attrs)
      assert portfolio.name == valid_attrs.name
      assert portfolio.ticker == valid_attrs.ticker
    end

    test "update_porfolio/2 with invalid data creates an error changeset" do
      {_user, portfolio} = portfolio_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.update_portfolio(portfolio, %{name: nil})
      assert {:error, %Ecto.Changeset{}} = Investment.update_portfolio(portfolio, %{ticker: nil})
      assert portfolio == Investment.get_portfolio!(portfolio.id) |> Repo.preload(:user)
    end

    test "delete_portfolio/1 deletes a portfolio" do
      {_user, portfolio} = portfolio_fixture()

      assert {:ok, %Portfolio{}} = Investment.delete_portfolio(portfolio)
      assert_raise Ecto.NoResultsError, fn -> Investment.get_portfolio!(portfolio.id) end
    end

    # TODO: fails to delete portfolio with positions

    test "change_portfolio/1 returns a portfolio changeset" do
      {_user, portfolio} = portfolio_fixture()

      assert %Ecto.Changeset{} = Investment.change_portfolio(portfolio)
    end

    test "create_position/2 with valid data creates a new position" do
      {_user, portfolio} = portfolio_fixture()
      valid_attrs = %{ticker: "TSLA"}

      assert {:ok, %Position{} = position} = Investment.create_position(portfolio, valid_attrs)

      assert position.portfolio_id == portfolio.id
      assert position.portfolio == portfolio
      assert position.ticker == valid_attrs.ticker
    end

    test "create_position/2 with invalid data creates an error changeset" do
      {_user, portfolio} = portfolio_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.create_position(portfolio, %{})
    end

    test "update_position/2 with valid data updates the position" do
      {_user, portfolio, position} = position_fixture()
    end
  end
end

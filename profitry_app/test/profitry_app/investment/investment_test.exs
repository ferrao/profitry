defmodule ProfitryApp.Investment.InvestmentTest do
  use ProfitryApp.DataCase, async: true

  import ProfitryApp.{InvestmentFixtures, AccountsFixtures}

  alias ProfitryApp.Investment

  describe "investment" do
    test "list_porfolios/0 returns portfolios" do
      user = user_fixture()
      portfolio = portfolio_fixture(user)

      assert Investment.list_portfolios() |> Repo.preload(:user) == [portfolio]
    end

    test "list_porfolios/1 returns portfolios for a user" do
      user = user_fixture()
      portfolio = portfolio_fixture(user)

      assert Investment.list_portfolios(user) |> Repo.preload(:user) == [portfolio]
    end
  end
end

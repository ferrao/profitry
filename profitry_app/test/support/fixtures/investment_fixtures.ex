defmodule ProfitryApp.InvestmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ProfitryApp.Investment` context.
  """

  import ProfitryApp.AccountsFixtures

  @doc """
  Generate a portfolio for a user
  """
  def portfolio_fixture(user, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        name: "Interactive Brokers",
        ticker: "IBKR"
      })

    {:ok, portfolio} =
      ProfitryApp.Investment.create_portfolio(user, attrs)

    portfolio
  end

  def portfolio_fixture() do
    user = user_fixture()
    portfolio = portfolio_fixture(user)
    {user, portfolio}
  end

  @doc """
  Generate a position for a portfolio
  """
  def position_fixture(portfolio, attrs \\ %{}) do
    attrs = attrs |> Enum.into(%{ticker: "TSLA"})
    {:ok, position} = ProfitryApp.Investment.create_position(portfolio, attrs)

    position
  end

  def position_fixture() do
    {user, portfolio} = portfolio_fixture()
    position = position_fixture(portfolio)

    {user, portfolio, position}
  end
end

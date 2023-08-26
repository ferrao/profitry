defmodule ProfitryApp.InvestmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ProfitryApp.Investment` context.
  """

  @doc """
  Generate a portfolio.
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
end

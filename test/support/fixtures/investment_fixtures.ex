defmodule Profitry.InvestmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Profitry.Investment` context.
  """

  @doc """
  Generate a portfolio for a user
  """
  def portfolio_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{broker: "IBKR", description: "Investment Portfolio"})

    {:ok, portfolio} =
      Profitry.Investment.create_portfolio(attrs)

    portfolio
  end
end

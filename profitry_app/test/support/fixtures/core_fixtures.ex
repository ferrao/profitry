defmodule ProfitryApp.InvestmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ProfitryApp.Investment` context.
  """

  @doc """
  Generate a portfolio.
  """
  def portfolio_fixture(attrs \\ %{}) do
    {:ok, portfolio} =
      attrs
      |> Enum.into(%{
        name: "some name",
        tikr: "some tikr"
      })
      |> ProfitryApp.Investment.create_portfolio()

    portfolio
  end
end

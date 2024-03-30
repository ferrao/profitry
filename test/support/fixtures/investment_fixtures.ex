defmodule Profitry.InvestmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Profitry.Investment` context.
  """
  alias Profitry.Investment.Schema.Portfolio

  @doc """
  Generate a portfolio for a user
  """
  def portfolio_fixture(attrs \\ %{}) do
    portfolio = %Portfolio{broker: "IBKR", description: "Investment Portfolio"}
    Profitry.Repo.insert!(struct(portfolio, attrs))
  end
end

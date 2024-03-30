defmodule Profitry.InvestmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Profitry.Investment` context.
  """
  alias Profitry.Investment.Schema.{Portfolio, Position}

  @doc """
  Generate a portfolio 
  """
  def portfolio_fixture(attrs \\ %{}) do
    portfolio = %Portfolio{broker: "IBKR", description: "Investment Portfolio"}
    Profitry.Repo.insert!(struct(portfolio, attrs))
  end

  @doc """
  Generate a posittion for a portfolio
  """
  def position_fixture() do
    portfolio = portfolio_fixture()
    position = position_fixture(portfolio)
    {portfolio, position}
  end

  def position_fixture(portfolio, attrs \\ %{}) do
    %Position{ticker: "TSLA"}
    |> Position.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:portfolio, portfolio)
    |> Profitry.Repo.insert!()
  end
end

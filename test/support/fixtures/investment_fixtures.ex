defmodule Profitry.InvestmentFixtures do
  @moduledoc """

  This module defines test helpers for creating
  entities via the `Profitry.Investment` context.

  """
  alias Profitry.Repo
  alias Profitry.Investment.Schema.{Portfolio, Position, Order}

  @doc """

  Generate a portfolio 

  """
  def portfolio_fixture(attrs \\ %{}) do
    portfolio = %Portfolio{broker: "IBKR", description: "Investment Portfolio"}
    Repo.insert!(struct(portfolio, attrs))
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
    |> Repo.insert!()
  end

  @doc """

  Generates an order for a position

  """

  def order_fixture() do
    {portfolio, position} = position_fixture()
    order = order_fixture(position)

    {portfolio, position, order}
  end

  def order_fixture(position, attrs \\ %{}) do
    %Order{
      type: :buy,
      instrument: :stock,
      quantity: Decimal.new("1.3"),
      price: Decimal.new("123.7"),
      inserted_at: ~N[2023-01-01 12:00:07]
    }
    |> Order.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:position, position)
    |> Repo.insert!()
  end
end

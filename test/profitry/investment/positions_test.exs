defmodule Profitry.Investment.PositionsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Schema.Position

  describe "position" do
    test "create_position/2 with valid data creates a position" do
      portfolio = portfolio_fixture()
      attrs = %{ticker: "aapl"}

      assert {:ok, %Position{} = position} = Investment.create_position(portfolio, attrs)
      assert position.ticker == String.upcase(attrs.ticker)
      assert position.portfolio_id == portfolio.id
      assert position == Repo.get!(Position, position.id) |> Repo.preload(:portfolio)
    end

    test "create_position/2 with invalid data creates an error changeset" do
      portfolio = portfolio_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.create_position(portfolio, %{})
    end

    test "update_position/2 with valid data updates the position" do
      {portfolio, position} = position_fixture()
      attrs = %{ticker: "aapl"}

      assert {:ok, %Position{} = position} = Investment.update_position(position, attrs)
      assert position.ticker == String.upcase(attrs.ticker)
      assert position.portfolio_id == portfolio.id
    end

    test "update_position/2 with invalid data creates an error changeset" do
      {_portfolio, position} = position_fixture()
      attrs = %{ticker: nil}

      assert {:error, %Ecto.Changeset{}} = Investment.update_position(position, attrs)
    end
  end
end

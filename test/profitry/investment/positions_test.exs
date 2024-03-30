defmodule Profitry.Investment.PositionsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Positions
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

    test "change_positions/1 returns a position changeset" do
      {_portfolio, position} = position_fixture()

      assert %Ecto.Changeset{} = Positions.change_position(position)
    end

    test "delete_position/1 deletes position" do
      {_portfolio, position} = position_fixture()

      assert {:ok, %Position{}} = Investment.delete_position(position)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Position, position.id) end
    end

    test "delete_position/1 creates an error changeset for a position with orders" do
      {_portfolio, position, _order} = order_fixture()

      assert {:error, %Ecto.Changeset{} = changeset} = Investment.delete_position(position)
      assert ["Position contains orders"] = errors_on(changeset).orders
      assert position == Repo.get!(Position, position.id) |> Repo.preload(:portfolio)
    end
  end
end

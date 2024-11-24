defmodule Profitry.Investment.PositionsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Positions
  alias Profitry.Investment.Schema.{Position, Order, Option}

  describe "position" do
    test "create_position/2 with valid data creates a position" do
      portfolio = portfolio_fixture()
      attrs = %{ticker: "aapl"}

      assert {:ok, %Position{} = position} = Investment.create_position(portfolio, attrs)
      assert position.ticker === String.upcase(attrs.ticker)
      assert position.portfolio_id === portfolio.id
      assert position === Repo.get!(Position, position.id) |> Repo.preload(:portfolio)
    end

    test "create_position/2 with invalid data creates an error changeset" do
      portfolio = portfolio_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.create_position(portfolio, %{})
    end

    test "update_position/2 with valid data updates the position" do
      {portfolio, position} = position_fixture()
      attrs = %{ticker: "aapl"}

      assert {:ok, %Position{} = position} = Investment.update_position(position, attrs)
      assert position.ticker === String.upcase(attrs.ticker)
      assert position.portfolio_id === portfolio.id
    end

    test "update_position/2 with invalid data creates an error changeset" do
      {_portfolio, position} = position_fixture()
      attrs = %{ticker: nil}

      assert {:error, %Ecto.Changeset{}} = Investment.update_position(position, attrs)
    end

    test "change_position/1 returns a position changeset" do
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
      assert position === Repo.get!(Position, position.id) |> Repo.preload(:portfolio)
    end

    test "find_position/2 finds an existing position in a portfolio" do
      {portfolio, position} = position_fixture()

      assert %Position{ticker: ticker, id: id} =
               Investment.find_position(portfolio, position.ticker)

      assert id == position.id
      assert ticker == position.ticker
    end

    test "preload_orders/1 loads orders for a position" do
      {_portfolio, position, _order} = option_fixture()

      position = Positions.preload_orders(position)

      assert is_list(position.orders)
      assert [%Order{}] = position.orders
    end

    test "preload_orders/1 loads option for an order" do
      {_portfolio, position, _order} = option_fixture()

      position = Positions.preload_orders(position)

      assert [%Order{option: %Option{}}] = position.orders
    end
  end
end

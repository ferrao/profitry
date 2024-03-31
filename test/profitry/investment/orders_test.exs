defmodule Profitry.Investment.OrdersTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  # alias Profitry.Investment.Orders
  alias Profitry.Investment.Schema.Order

  describe "order" do
    test "create_order/2 with valid data but no option creates an order" do
      {_portfolio, position} = position_fixture()

      attrs = %{
        type: "buy",
        instrument: "option",
        quantity: "1.3",
        price: "132.3",
        inserted_at: "2024-01-01 12:00:07"
      }

      {:ok, %Order{} = order} = Investment.create_order(position, attrs)
      assert order.type == String.to_atom(attrs.type)
      assert order.instrument == String.to_atom(attrs.instrument)
      assert order.quantity == Decimal.new(attrs.quantity)
      assert order.price == Decimal.new(attrs.price)
      assert order.inserted_at == NaiveDateTime.from_iso8601!(attrs.inserted_at)

      assert order ==
               Repo.get(Order, order.id)
               |> Repo.preload(position: :portfolio)
    end

    test "create_order/2 with valid data and option creates an order" do
      {_portfolio, position} = position_fixture()

      attrs = %{
        type: "buy",
        instrument: "option",
        quantity: "1.3",
        price: "132.3",
        inserted_at: "2024-01-01 12:00:07",
        option: %{strike: 50, expiration: "2024-02-01"}
      }

      {:ok, %Order{} = order} = Investment.create_order(position, attrs)
      assert order.type == String.to_atom(attrs.type)
      assert order.instrument == String.to_atom(attrs.instrument)
      assert order.quantity == Decimal.new(attrs.quantity)
      assert order.price == Decimal.new(attrs.price)
      assert order.inserted_at == NaiveDateTime.from_iso8601!(attrs.inserted_at)

      assert order ==
               Repo.get(Order, order.id)
               |> Repo.preload(:option)
               |> Repo.preload(position: :portfolio)
    end

    test "create_order/2 with invalide data creates an error changeset" do
      {_portfolio, position} = position_fixture()
      assert {:error, %Ecto.Changeset{}} = Investment.create_order(position, %{})
    end

    test "list_orders/1 returns the orders for a position" do
      {_portfolio, position, order} = order_fixture()

      assert Investment.list_orders(position)
             |> Repo.preload(position: :portfolio) == [order]
    end

    test "get_order/1 returns existing order" do
      {_portfolio, _position, order} = order_fixture()

      assert order == Investment.get_order(order.id) |> Repo.preload(position: :portfolio)
    end

    test "get_order/1 returns nill for invalid order id" do
      assert Investment.get_order(999) == nil
    end

    test "update_order/2 with valid data updates order" do
      {_portfolio, _position, order} = order_fixture()

      attrs = %{
        instrument: "option",
        option: %{strike: 50, expiration: "2024-02-01"}
      }

      assert {:ok, %Order{} = order} =
               Investment.update_order(order |> Repo.preload(:option), attrs)

      assert order.instrument == String.to_atom(attrs.instrument)
      assert order.option.strike == attrs.option.strike
      assert order.option.expiration == Date.from_iso8601!(attrs.option.expiration)
    end

    test "update_order/2 with invalid data creates an error changeset" do
      {_portfolio, _position, order} = order_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.update_order(order, %{instrument: nil})
      assert {:error, %Ecto.Changeset{}} = Investment.update_order(order, %{price: nil})
    end
  end
end

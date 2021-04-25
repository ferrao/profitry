defmodule ProfitryTest do
  use ExUnit.Case

  alias Profitry

  test "creates a new position" do
    position = Profitry.new_position("aapl", %{type: :buy, quantity: 10, price: 100})

    assert position.ticker == "aapl"
    assert length(position.orders) == 1

    order = List.first(position.orders)
    assert order.type == :buy
    assert order.quantity == 10
    assert order.price == 100
  end

  test "adds an order to an existing position" do
    position = Profitry.new_position("aapl", %{type: :buy, quantity: 10, price: 100})
    position = Profitry.make_order(position, %{type: :sell, quantity: 5, price: 110})

    order = List.first(position.orders)
    assert order.type == :sell
    assert order.quantity == 5
    assert order.price == 110
  end

  test "creates a position report" do
    position = Profitry.new_position("aapl", %{type: :buy, quantity: 10, price: 100})
    position = Profitry.make_order(position, %{type: :sell, quantity: 5, price: 110})
    position = Profitry.make_order(position, %{type: :buy, quantity: 2, price: 120})

    report = Profitry.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == 690
    assert report.shares == 7
    assert report.cost_basis == 98.57
  end
end

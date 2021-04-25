defmodule ProfitryTest do
  use ExUnit.Case

  alias Profitry

  test "creates a new position with stocks" do
    position = Profitry.new_position("aapl", %{type: :buy, quantity: 10, price: 100})

    assert position.ticker == "aapl"
    assert length(position.orders) == 1

    order = List.first(position.orders)
    assert order.type == :buy
    assert order.quantity == "10"
    assert order.price == "100"
  end

  test "creates a new position with stock options" do
    position = Profitry.new_position("aapl", %{type: :buy, premium: 2.6})

    assert position.ticker == "aapl"
    assert length(position.orders) == 1

    order = List.first(position.orders)
    assert order.type == :buy
    assert order.premium == "2.6"
  end

  test "adds a stocks order to an existing position" do
    position = Profitry.new_position("aapl", %{type: :buy, quantity: 10, price: 100})
    position = Profitry.make_order(position, %{type: :sell, quantity: 5, price: 110})

    order = List.first(position.orders)
    assert order.type == :sell
    assert order.quantity == "5"
    assert order.price == "110"
  end

  test "adds a stock options order to an existing position" do
    position = Profitry.new_position("aapl", %{type: :buy, quantity: 10, price: 100})
    position = Profitry.make_order(position, %{type: :sell, premium: 1.5})

    order = List.first(position.orders)
    assert order.type == :sell
    assert order.premium == "1.5"
  end

  test "creates a position report" do
    position = Profitry.new_position("aapl", %{type: :buy, quantity: 10, price: 100})
    position = Profitry.make_order(position, %{type: :sell, premium: 1.5})
    position = Profitry.make_order(position, %{type: :sell, quantity: 5, price: 110})
    position = Profitry.make_order(position, %{type: :buy, quantity: 2, price: 120})
    position = Profitry.make_order(position, %{type: :buy, premium: 0.5})

    report = Profitry.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "590.00"
    assert report.shares == "7.00"
    assert report.cost_basis == "84.29"
  end

  test "creates a report for a position with stock options only" do
    position = Profitry.new_position("aapl", %{type: :sell, premium: 1.5})
    position = Profitry.make_order(position, %{type: :buy, premium: 0.5})

    report = Profitry.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "-100.00"
    assert report.shares == "0.00"
    assert report.cost_basis == "0.00"
  end

  test "creates a report for a position with no stocks" do
    position = Profitry.new_position("aapl", %{type: :sell, quantity: 10, price: 100})
    position = Profitry.make_order(position, %{type: :buy, quantity: 10, price: 50})

    report = Profitry.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "-500.00"
    assert report.shares == "0.00"
    assert report.cost_basis == "0.00"
  end
end

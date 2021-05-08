defmodule ProfitryTest do
  use ExUnit.Case

  alias Profitry.{StockOrder, OptionsOrder, Position}

  test "creates a new position with stocks" do
    position = Position.new_position("aapl", %StockOrder{type: :buy, quantity: 10, price: 100})

    assert position.ticker == "aapl"
    assert length(position.orders) == 1

    order = List.first(position.orders)
    assert order.type == :buy
    assert order.quantity == "10"
    assert order.price == "100"
  end

  test "creates a new position with stock options" do
    position = Position.new_position("aapl", %OptionsOrder{type: :buy, premium: 2.6})

    assert position.ticker == "aapl"
    assert length(position.orders) == 1

    order = List.first(position.orders)
    assert order.type == :buy
    assert order.premium == "2.6"
  end

  test "adds a stocks order to an existing position" do
    position = Position.new_position("aapl", %StockOrder{type: :buy, quantity: 10, price: 100})
    position = Position.make_order(position, %StockOrder{type: :sell, quantity: 5, price: 110})

    order = List.first(position.orders)
    assert order.type == :sell
    assert order.quantity == "5"
    assert order.price == "110"
  end

  test "adds a stock options order to an existing position" do
    position = Position.new_position("aapl", %StockOrder{type: :buy, quantity: 10, price: 100})
    position = Position.make_order(position, %OptionsOrder{type: :sell, premium: 1.5})

    order = List.first(position.orders)
    assert order.type == :sell
    assert order.premium == "1.5"
  end

  test "creates a position report" do
    position = Position.new_position("aapl", %StockOrder{type: :buy, quantity: 10, price: 100})
    position = Position.make_order(position, %OptionsOrder{type: :sell, premium: 1.5})
    position = Position.make_order(position, %StockOrder{type: :sell, quantity: 5, price: 110})
    position = Position.make_order(position, %StockOrder{type: :buy, quantity: 2, price: 120})
    position = Position.make_order(position, %OptionsOrder{type: :buy, premium: 0.5})

    report = Profitry.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "590.00"
    assert report.shares == "7.00"
    assert report.cost_basis == "84.29"
  end

  test "creates a report for a position with stock options only" do
    position = Position.new_position("aapl", %OptionsOrder{type: :sell, premium: 1.5})
    position = Position.make_order(position, %OptionsOrder{type: :buy, premium: 0.5})

    report = Profitry.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "-100.00"
    assert report.shares == "0.00"
    assert report.cost_basis == "0.00"
  end

  test "creates a report for a position with no stocks" do
    position = Position.new_position("aapl", %StockOrder{type: :sell, quantity: 10, price: 100})
    position = Position.make_order(position, %StockOrder{type: :buy, quantity: 10, price: 50})

    report = Profitry.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "-500.00"
    assert report.shares == "0.00"
    assert report.cost_basis == "0.00"
  end

  test "creates a new portfolio" do
    portfolio = Profitry.new_portfolio(:tasty, "TastyWorks Portfolio")

    assert portfolio.id == :tasty
    assert portfolio.description == "TastyWorks Portfolio"
  end

  test "creates a new position on a portfolio" do
    order = %StockOrder{type: :buy, quantity: 10, price: 100}
    portfolio = Profitry.new_portfolio(:tasty, "TastyWorks Portfolio")
    portfolio = Profitry.make_order(portfolio, "aapl", order)
    position = portfolio.positions[:AAPL]

    assert position.ticker == "aapl"
    assert length(position.orders) == 1
    assert hd(position.orders).type == :buy
    assert hd(position.orders).quantity == "10"
    assert hd(position.orders).price == "100"
  end

  test "adds an order to a portfolio position" do
    order = %StockOrder{type: :buy, quantity: 10, price: 100}
    portfolio = Profitry.new_portfolio(:tasty, "TastyWorks Portfolio")
    portfolio = Profitry.make_order(portfolio, "aapl", order)
    portfolio = Profitry.make_order(portfolio, "aapl", %{order | quantity: 1, price: 10})
    position = portfolio.positions[:AAPL]

    assert position.ticker == "aapl"
    assert length(position.orders) == 2
    assert hd(position.orders).type == :buy
    assert hd(position.orders).quantity == "1"
    assert hd(position.orders).price == "10"
  end
end

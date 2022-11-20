defmodule ProfitryTest do
  use ExUnit.Case

  alias Profitry.Domain.{StockOrder, OptionsOrder, Position, Report, Portfolio}

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
    position =
      Position.new_position("aapl", %OptionsOrder{type: :buy, contracts: 3, premium: 2.6})

    assert position.ticker == "aapl"
    assert length(position.orders) == 1

    order = List.first(position.orders)
    assert order.type == :buy
    assert order.contracts == "3"
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

  test "adds a stocks order with partial shares to an existing position" do
    position = Position.new_position("aapl", %StockOrder{type: :buy, quantity: 10, price: 100})
    position = Position.make_order(position, %StockOrder{type: :sell, quantity: 5.5, price: 110})

    order = List.first(position.orders)
    assert order.type == :sell
    assert order.quantity == "5.5"
    assert order.price == "110"
  end

  test "adds a stock options order to an existing position" do
    position = Position.new_position("aapl", %StockOrder{type: :buy, quantity: 10, price: 100})

    position =
      Position.make_order(position, %OptionsOrder{type: :sell, contracts: 3, premium: 1.5})

    order = List.first(position.orders)
    assert order.type == :sell
    assert order.contracts == "3"
    assert order.premium == "1.5"
  end

  test "creates a position report" do
    position = Position.new_position("aapl", %StockOrder{type: :buy, quantity: 10, price: 100})

    position =
      Position.make_order(position, %OptionsOrder{type: :sell, contracts: 2, premium: 0.75})

    position = Position.make_order(position, %StockOrder{type: :sell, quantity: 5, price: 110})
    position = Position.make_order(position, %StockOrder{type: :buy, quantity: 2.5, price: 120})

    position =
      Position.make_order(position, %OptionsOrder{type: :buy, contracts: 2, premium: 0.25})

    report = Report.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "650.00"
    assert report.shares == "7.50"
    assert report.cost_basis == "86.67"
  end

  test "creates a report for a position with stock options only" do
    position =
      Position.new_position("aapl", %OptionsOrder{type: :sell, contracts: 1, premium: 1.5})

    position =
      Position.make_order(position, %OptionsOrder{type: :buy, contracts: 2, premium: 0.25})

    report = Report.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "-100.00"
    assert report.shares == "0.00"
    assert report.cost_basis == "0.00"
  end

  test "creates a report for a position with no stocks" do
    position = Position.new_position("aapl", %StockOrder{type: :sell, quantity: 10, price: 100})
    position = Position.make_order(position, %StockOrder{type: :buy, quantity: 10, price: 50})

    report = Report.make_report(position)

    assert report.ticker == "aapl"
    assert report.investment == "-500.00"
    assert report.shares == "0.00"
    assert report.cost_basis == "0.00"
  end

  test "creates a new portfolio" do
    portfolio = Portfolio.new_portfolio("tasty", "TastyWorks Portfolio")

    assert portfolio.id == "tasty"
    assert portfolio.name == "TastyWorks Portfolio"
  end

  test "creates a new position on an empty portfolio" do
    order = %StockOrder{type: :buy, quantity: 10, price: 100}
    portfolio = Portfolio.new_portfolio("tasty", "TastyWorks Portfolio")
    portfolio = Portfolio.make_order(portfolio, "aapl", order)
    position = portfolio.positions[:AAPL]

    assert position.ticker == "aapl"
    assert length(position.orders) == 1
    assert hd(position.orders).type == :buy
    assert hd(position.orders).quantity == "10"
    assert hd(position.orders).price == "100"
  end

  test "creates a new position on an non empty portfolio" do
    order = %StockOrder{type: :buy, quantity: 10, price: 100}
    portfolio = Portfolio.new_portfolio("tasty", "TastyWorks Portfolio")
    portfolio = Portfolio.make_order(portfolio, "aapl", order)
    portfolio = Portfolio.make_order(portfolio, "tsla", order)

    position = portfolio.positions[:TSLA]

    assert position.ticker == "tsla"
    assert length(position.orders) == 1
    assert hd(position.orders).type == :buy
    assert hd(position.orders).quantity == "10"
    assert hd(position.orders).price == "100"
  end

  test "adds an order to a portfolio position" do
    order = %StockOrder{type: :buy, quantity: 10, price: 100}
    portfolio = Portfolio.new_portfolio("tasty", "TastyWorks Portfolio")
    portfolio = Portfolio.make_order(portfolio, "aapl", order)
    portfolio = Portfolio.make_order(portfolio, "aapl", %{order | quantity: 1, price: 10})
    position = portfolio.positions[:AAPL]

    assert position.ticker == "aapl"
    assert length(position.orders) == 2
    assert hd(position.orders).type == :buy
    assert hd(position.orders).quantity == "1"
    assert hd(position.orders).price == "10"
  end

  test "creates a portfolio report" do
    order = %StockOrder{type: :buy, quantity: 10, price: 100}
    portfolio = Portfolio.new_portfolio("tasty", "TastyWorks Portfolio")
    portfolio = Portfolio.make_order(portfolio, "aapl", order)
    portfolio = Portfolio.make_order(portfolio, "aapl", %{order | quantity: 1, price: 10})
    portfolio = Portfolio.make_order(portfolio, "tsla", order)
    portfolio = Portfolio.make_order(portfolio, "tsla", %{order | quantity: 2, price: 20})

    [apple_report, tesla_report] = Portfolio.make_report(portfolio)

    assert apple_report.cost_basis == "91.82"
    assert apple_report.investment == "1010.00"
    assert apple_report.shares == "11.00"
    assert apple_report.ticker == "aapl"
    assert tesla_report.cost_basis == "86.67"
    assert tesla_report.investment == "1040.00"
    assert tesla_report.shares == "12.00"
    assert tesla_report.ticker == "tsla"
  end
end

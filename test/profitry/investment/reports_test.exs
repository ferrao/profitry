defmodule Profitry.Investment.ReportsTest do
  use ExUnit.Case

  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Investment
  alias Profitry.Investment.Reports
  alias Profitry.Investment.Schema.{PositionReport, OptionsReport, Order, Option, Position}

  @report %PositionReport{
    ticker: "TSLA",
    investment: Decimal.new("23400"),
    shares: Decimal.new("100"),
    price: Decimal.new("234"),
    long_options: [
      %OptionsReport{
        strike: 200,
        expiration: ~D[2023-01-01],
        contracts: 2,
        investment: Decimal.new("140.20")
      }
    ],
    short_options: [
      %OptionsReport{
        strike: 250,
        expiration: ~D[2023-01-01],
        contracts: 2,
        investment: Decimal.new("320.40")
      }
    ]
  }

  @quote %Quote{
    ticker: "TSLA",
    price: Decimal.new("231.5")
  }

  @position %Position{
    ticker: "TSLA",
    orders: [
      %Order{type: :buy, instrument: :stock, quantity: 10, price: Decimal.new("100")},
      %Order{
        type: :sell,
        instrument: :option,
        quantity: 2,
        price: Decimal.new("0.75"),
        option: %Option{strike: 110, expiration: ~D[2023-01-01]}
      },
      %Order{type: :sell, instrument: :stock, quantity: 5, price: Decimal.new("110")},
      %Order{
        type: :buy,
        instrument: :stock,
        quantity: Decimal.new("2.5"),
        price: Decimal.new("120")
      },
      %Order{
        type: :buy,
        instrument: :option,
        quantity: 2,
        price: Decimal.new("0.25"),
        option: %Option{strike: 120, expiration: ~D[2023-01-01]}
      }
    ]
  }

  describe "position report" do
    test "creates a position report on a portfolio position" do
      report = Investment.make_report(@position, @quote)
      [long_option | _t] = report.long_options
      [short_option | _t] = report.short_options

      assert report.ticker == "TSLA"
      assert Decimal.compare(report.price, @quote.price) === :eq
      assert Decimal.compare(report.value |> Decimal.round(2), Decimal.new("1736.25")) === :eq
      assert Decimal.compare(report.investment |> Decimal.round(2), Decimal.new("650")) === :eq
      assert Decimal.compare(report.shares |> Decimal.round(2), Decimal.new("7.50")) === :eq
      assert Decimal.compare(report.cost_basis |> Decimal.round(2), Decimal.new("86.67")) === :eq

      assert long_option.strike === 120
      assert long_option.contracts === 2
      assert long_option.expiration === ~D[2023-01-01]

      assert Decimal.compare(long_option.investment |> Decimal.round(2), Decimal.new("50")) ===
               :eq

      assert short_option.strike === 110
      assert short_option.contracts === 2
      assert short_option.expiration === ~D[2023-01-01]

      assert Decimal.compare(short_option.investment |> Decimal.round(2), Decimal.new("-150")) ===
               :eq
    end

    test "position report without quote contains no price, value or profit" do
      report = Investment.make_report(@position)
      assert Decimal.compare(report.price, Decimal.new(0)) === :eq
      assert Decimal.compare(report.value, Decimal.new(0)) === :eq
      assert Decimal.compare(report.profit, Decimal.new(0)) === :eq
    end

    test "buying shares" do
      order = %Order{
        type: :buy,
        instrument: :stock,
        quantity: 3,
        price: Decimal.new("252.7")
      }

      report = Reports.calculate_order(@report, order)

      assert Decimal.compare(report.shares, "103") === :eq
      assert Decimal.compare(report.investment, "24158.1") === :eq

      assert report.long_options == [
               %OptionsReport{
                 strike: 200,
                 contracts: 2,
                 expiration: ~D[2023-01-01],
                 investment: Decimal.new("140.20")
               }
             ]

      assert report.short_options == [
               %OptionsReport{
                 strike: 250,
                 contracts: 2,
                 expiration: ~D[2023-01-01],
                 investment: Decimal.new("320.40")
               }
             ]
    end

    test "selling shares" do
      order = %Order{
        type: :sell,
        instrument: :stock,
        quantity: 3,
        price: Decimal.new("252.7")
      }

      report = Reports.calculate_order(@report, order)

      assert Decimal.compare(report.shares, 97) === :eq
      assert Decimal.compare(report.investment, "22641.9") === :eq

      assert report.long_options == [
               %OptionsReport{
                 strike: 200,
                 contracts: 2,
                 expiration: ~D[2023-01-01],
                 investment: Decimal.new("140.20")
               }
             ]

      assert report.short_options == [
               %OptionsReport{
                 strike: 250,
                 contracts: 2,
                 expiration: ~D[2023-01-01],
                 investment: Decimal.new("320.40")
               }
             ]
    end
  end

  test "buying premium" do
    order = %Order{
      type: :buy,
      instrument: :option,
      quantity: 2,
      price: Decimal.new("1.7"),
      option: %Option{
        strike: 200,
        expiration: ~D[2023-01-01]
      }
    }

    report = Reports.calculate_order(@report, order)

    assert report.ticker == @report.ticker
    assert report.short_options == @report.short_options
    assert Decimal.compare(report.shares, @report.shares) === :eq
    assert Decimal.compare(report.price, @report.price) === :eq

    assert Decimal.compare(report.investment, "23740") === :eq

    assert report.long_options == [
             %OptionsReport{
               strike: 200,
               expiration: ~D[2023-01-01],
               contracts: 4,
               investment: Decimal.new("480.20")
             }
           ]
  end

  test "selling premium" do
    order = %Order{
      type: :sell,
      instrument: :option,
      quantity: 2,
      price: Decimal.new("1.7"),
      option: %Option{
        strike: 250,
        expiration: ~D[2023-01-01]
      }
    }

    report = Reports.calculate_order(@report, order)

    assert report.ticker == @report.ticker
    assert report.long_options == @report.long_options
    assert Decimal.compare(report.shares, @report.shares) === :eq
    assert Decimal.compare(report.price, @report.price) === :eq

    assert Decimal.compare(report.investment, "23060") === :eq

    assert report.short_options == [
             %OptionsReport{
               strike: 250,
               expiration: ~D[2023-01-01],
               contracts: 4,
               investment: Decimal.new("-19.60")
             }
           ]
  end
end

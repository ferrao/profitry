defmodule Profitry.Investment.ReportsTest do
  use ExUnit.Case

  # alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Investment.Reports
  alias Profitry.Investment.Schema.{PositionReport, OptionsReport, Order, Option}

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

  # @quote %Quote{
  #   ticker: "TSLA",
  #   price: Decimal.new("231.5")
  # }

  describe "position report" do
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

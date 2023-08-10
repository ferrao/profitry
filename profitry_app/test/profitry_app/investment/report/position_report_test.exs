defmodule ProfitryApp.Investment.Report.PositionReportTest do
  use ExUnit.Case

  alias ProfitryApp.Investment.Report.OptionsReport
  alias ProfitryApp.Investment.{Position, Option, Report, Order}
  alias ProfitryApp.Investment.Report.{PositionReport, OptionsReport}
  alias ProfitryApp.Exchanges.Quote

  @report %Report{
    position_id: 12345,
    ticker: "TSLA",
    investment: Decimal.new("23400"),
    shares: Decimal.new("100"),
    price: Decimal.new("234"),
    long_options: [
      %OptionsReport{
        strike: 200,
        expiration: ~D[2023-01-01],
        contracts: 2
      }
    ],
    short_options: [
      %OptionsReport{
        strike: 250,
        expiration: ~D[2023-01-01],
        contracts: 2
      }
    ]
  }

  @quote %Quote{
    ticker: "TSLA",
    price: Decimal.new("231.5")
  }

  describe "position report" do
    test "creates a report on a portfolio position" do
      position = %Position{
        id: 1,
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

      report = PositionReport.make_report(position, @quote)

      assert report.ticker == "TSLA"
      assert Decimal.compare(report.investment, Decimal.new("650.00")) == :eq
      assert Decimal.compare(report.shares, Decimal.new("7.50")) == :eq
      assert Decimal.compare(report.cost_basis, Decimal.new("86.67")) == :eq

      assert report.long_options == [
               %OptionsReport{
                 strike: 120,
                 contracts: 2,
                 expiration: ~D[2023-01-01],
                 value: 0
               }
             ]

      assert report.short_options == [
               %OptionsReport{
                 strike: 110,
                 contracts: 2,
                 expiration: ~D[2023-01-01],
                 value: 0
               }
             ]
    end
  end

  describe "calculates impact of an order in an existing position" do
    test "buying shares" do
      order = %Order{
        type: :buy,
        instrument: :stock,
        quantity: 3,
        price: Decimal.new("252.7")
      }

      report = PositionReport.calculate_order(@report, order)

      assert Decimal.compare(report.shares, Decimal.new("103")) == :eq
      assert Decimal.compare(report.investment, Decimal.new("24158.1")) == :eq

      assert report.long_options == [
               %OptionsReport{strike: 200, contracts: 2, expiration: ~D[2023-01-01]}
             ]

      assert report.short_options == [
               %OptionsReport{strike: 250, contracts: 2, expiration: ~D[2023-01-01]}
             ]
    end

    test "selling shares" do
      order = %Order{
        type: :sell,
        instrument: :stock,
        quantity: 3,
        price: Decimal.new("252.7")
      }

      report = PositionReport.calculate_order(@report, order)

      assert Decimal.compare(report.shares, Decimal.new("97")) == :eq
      assert Decimal.compare(report.investment, Decimal.new("22641.9")) == :eq

      assert report.long_options == [
               %OptionsReport{strike: 200, contracts: 2, expiration: ~D[2023-01-01]}
             ]

      assert report.short_options == [
               %OptionsReport{strike: 250, contracts: 2, expiration: ~D[2023-01-01]}
             ]
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

      report = PositionReport.calculate_order(@report, order)

      assert Decimal.compare(report.shares, Decimal.new("100")) == :eq
      assert Decimal.compare(report.investment, Decimal.new("23740")) == :eq

      assert report.short_options == [
               %OptionsReport{strike: 250, contracts: 2, expiration: ~D[2023-01-01]}
             ]

      assert report.long_options == [
               %OptionsReport{
                 strike: 200,
                 expiration: ~D[2023-01-01],
                 contracts: 4
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

      report = PositionReport.calculate_order(@report, order)

      assert Decimal.compare(report.shares, Decimal.new("100")) == :eq
      assert Decimal.compare(report.investment, Decimal.new("23060")) == :eq

      assert report.long_options == [
               %OptionsReport{strike: 200, contracts: 2, expiration: ~D[2023-01-01]}
             ]

      assert report.short_options == [
               %OptionsReport{
                 strike: 250,
                 expiration: ~D[2023-01-01],
                 contracts: 4
               }
             ]
    end
  end

  describe "calculates a position cost basis" do
    test "position report with no shares" do
      report =
        PositionReport.calculate_cost_basis(@report, false)

      assert Decimal.compare(report.cost_basis, Decimal.new("0")) == :eq
    end

    test "position report with shares" do
      report =
        PositionReport.calculate_cost_basis(@report, true)

      assert Decimal.compare(report.cost_basis, Decimal.new("234")) == :eq
    end
  end

  describe "calculates the position profit" do
    test "no quote available" do
      report =
        PositionReport.calculate_profit(@report, nil)

      assert Decimal.compare(report.profit, Decimal.new("0")) == :eq
    end

    test "quote available" do
      report =
        PositionReport.calculate_profit(@report, @quote)

      assert Decimal.compare(report.profit, Decimal.new("-250")) == :eq
    end
  end

  describe "calculates the position value" do
    test "no quote available" do
      report =
        PositionReport.calculate_value(@report, nil)

      assert Decimal.compare(report.value, Decimal.new("0")) == :eq
    end

    test "quote available" do
      report =
        PositionReport.calculate_value(@report, @quote)

      assert Decimal.compare(report.value, Decimal.new("23150")) == :eq
    end
  end
end

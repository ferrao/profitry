defmodule Profitry.Investment.ReportsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Investment
  alias Profitry.Investment.Reports
  alias Profitry.Investment.Schema.{PositionReport, OptionsReport, Order, Option, Position}

  @report %PositionReport{
    id: 666,
    ticker: "TSLA",
    investment: Decimal.new("23400"),
    shares: Decimal.new("100"),
    price: Decimal.new("234"),
    long_options: [
      %OptionsReport{
        type: :call,
        strike: Decimal.new("200"),
        expiration: ~D[2023-01-01],
        contracts: Decimal.new("2"),
        investment: Decimal.new("140.20")
      }
    ],
    short_options: [
      %OptionsReport{
        type: :put,
        strike: Decimal.new("250"),
        expiration: ~D[2023-01-01],
        contracts: Decimal.new("2"),
        investment: Decimal.new("320.40")
      }
    ]
  }

  @quote %Quote{
    exchange: "IBKR",
    ticker: "TSLA",
    price: Decimal.new("231.5"),
    timestamp: ~N[2023-01-01 16:30:00]
  }

  @position %Position{
    id: 666,
    ticker: "TSLA",
    orders: [
      %Order{
        id: 1,
        type: :buy,
        instrument: :stock,
        quantity: Decimal.new("10"),
        price: Decimal.new("100"),
        inserted_at: ~N[2022-12-24 16:30:00]
      },
      %Order{
        id: 2,
        type: :sell,
        instrument: :option,
        quantity: Decimal.new("2"),
        price: Decimal.new("0.75"),
        option: %Option{
          type: :put,
          strike: Decimal.new("110"),
          expiration: ~D[2023-01-02],
          order_id: 2
        },
        inserted_at: ~N[2022-12-24 16:30:00]
      },
      %Order{
        id: 3,
        type: :buy,
        instrument: :stock,
        quantity: Decimal.new("2.5"),
        price: Decimal.new("120"),
        inserted_at: ~N[2022-12-25 16:30:00]
      },
      %Order{
        id: 4,
        type: :buy,
        instrument: :option,
        quantity: Decimal.new("2"),
        price: Decimal.new("0.25"),
        option: %Option{
          type: :call,
          strike: Decimal.new("120"),
          expiration: ~D[2023-01-01],
          order_id: 4
        },
        inserted_at: ~N[2022-12-25 16:30:00]
      },
      %Order{
        id: 5,
        type: :sell,
        instrument: :stock,
        quantity: Decimal.new("5"),
        price: Decimal.new("110"),
        inserted_at: ~N[2023-02-03 16:30:00]
      }
    ]
  }

  describe "position report" do
    test "creates a position report on a portfolio position" do
      report = Investment.make_report(@position, @quote)
      [long_option | _t] = report.long_options
      [short_option | _t] = report.short_options

      assert report.id == 666
      assert report.ticker == "TSLA"
      assert Decimal.compare(report.price, @quote.price) === :eq
      assert Decimal.compare(report.value |> Decimal.round(2), Decimal.new("1736.25")) === :eq
      assert Decimal.compare(report.investment |> Decimal.round(2), Decimal.new("650")) === :eq
      assert Decimal.compare(report.shares |> Decimal.round(2), Decimal.new("7.50")) === :eq
      assert Decimal.compare(report.cost_basis |> Decimal.round(2), Decimal.new("86.67")) === :eq

      assert long_option.type === :call
      assert long_option.strike === Decimal.new("120")
      assert long_option.contracts === Decimal.new("2")
      assert long_option.expiration === ~D[2023-01-01]

      assert Decimal.compare(
               long_option.investment |> Decimal.round(2),
               Decimal.new("50")
             ) === :eq

      assert short_option.type === :put
      assert short_option.strike === Decimal.new("110")
      assert short_option.contracts === Decimal.new("2")
      assert short_option.expiration === ~D[2023-01-02]

      assert Decimal.compare(
               short_option.investment |> Decimal.round(2),
               Decimal.new("-150")
             ) === :eq
    end

    test "position report without quote contains no price, value or profit" do
      report = Investment.make_report(@position)
      assert Decimal.compare(report.price, Decimal.new(0)) === :eq
      assert Decimal.compare(report.value, Decimal.new(0)) === :eq
      assert Decimal.compare(report.profit, Decimal.new(0)) === :eq
    end

    test "adjusts position report when applicable split is found" do
      split_fixture()
      split_fixture(%{date: ~D[2022-12-01]})

      report = Investment.make_report(@position)
      long_option = Enum.at(report.long_options, 0)
      short_option = Enum.at(report.short_options, 0)

      assert Decimal.compare(report.investment, Decimal.new("650")) === :eq
      assert Decimal.compare(report.shares, Decimal.new("32.5")) === :eq
      assert Decimal.compare(report.cost_basis, Decimal.new("20")) === :eq

      assert Decimal.compare(long_option.investment, Decimal.new("50")) === :eq
      assert Decimal.compare(long_option.contracts, Decimal.new("2")) === :eq
      assert Decimal.compare(long_option.strike, Decimal.new("120")) === :eq

      assert Decimal.compare(short_option.investment, Decimal.new("-150")) === :eq
      assert Decimal.compare(short_option.contracts, Decimal.new("6")) === :eq

      assert Decimal.compare(
               short_option.strike |> Decimal.round(2),
               Decimal.new("36.67")
             ) === :eq
    end

    test "adjusts position report when applicable reverse split is found" do
      split_fixture(%{reverse: true})
      split_fixture(%{date: ~D[2022-12-01]})

      position = %Position{
        @position
        | orders:
            Enum.concat(
              @position.orders,
              [
                %Order{
                  id: 6,
                  type: :buy,
                  instrument: :stock,
                  quantity: Decimal.new("2"),
                  price: Decimal.new("100"),
                  inserted_at: ~N[2023-02-03 16:30:00]
                }
              ]
            )
      }

      report = Investment.make_report(position)
      long_option = Enum.at(report.long_options, 0)
      short_option = Enum.at(report.short_options, 0)

      assert Decimal.compare(report.investment, Decimal.new("850")) === :eq
      assert Decimal.compare(report.shares |> Decimal.round(2), Decimal.new("1.17")) === :eq
      assert Decimal.compare(report.cost_basis |> Decimal.round(2), Decimal.new("728.57")) === :eq

      assert Decimal.compare(long_option.investment, Decimal.new("50")) === :eq
      assert Decimal.compare(long_option.contracts, Decimal.new("2")) === :eq
      assert Decimal.compare(long_option.strike, Decimal.new("120")) === :eq

      assert Decimal.compare(short_option.investment, Decimal.new("-150")) === :eq
      assert Decimal.compare(short_option.strike, Decimal.new("330")) === :eq

      assert Decimal.compare(
               short_option.contracts |> Decimal.round(2),
               Decimal.new("0.67")
             ) === :eq
    end

    test "buying shares" do
      order = %Order{
        type: :buy,
        instrument: :stock,
        quantity: Decimal.new("3"),
        price: Decimal.new("252.7")
      }

      report = Reports.calculate_order(@report, order)

      assert Decimal.compare(report.shares, "103") === :eq
      assert Decimal.compare(report.investment, "24158.1") === :eq

      assert report.long_options == [
               %OptionsReport{
                 type: :call,
                 strike: Decimal.new("200"),
                 contracts: Decimal.new("2"),
                 expiration: ~D[2023-01-01],
                 investment: Decimal.new("140.20")
               }
             ]

      assert report.short_options == [
               %OptionsReport{
                 type: :put,
                 strike: Decimal.new("250"),
                 contracts: Decimal.new("2"),
                 expiration: ~D[2023-01-01],
                 investment: Decimal.new("320.40")
               }
             ]
    end

    test "selling shares" do
      order = %Order{
        type: :sell,
        instrument: :stock,
        quantity: Decimal.new("3"),
        price: Decimal.new("252.7")
      }

      report = Reports.calculate_order(@report, order)

      assert Decimal.compare(report.shares, Decimal.new("97")) === :eq
      assert Decimal.compare(report.investment, "22641.9") === :eq

      assert report.long_options == [
               %OptionsReport{
                 type: :call,
                 strike: Decimal.new("200"),
                 contracts: Decimal.new("2"),
                 expiration: ~D[2023-01-01],
                 investment: Decimal.new("140.20")
               }
             ]

      assert report.short_options == [
               %OptionsReport{
                 type: :put,
                 strike: Decimal.new("250"),
                 contracts: Decimal.new("2"),
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
      quantity: Decimal.new("2"),
      price: Decimal.new("1.7"),
      option: %Option{
        type: :call,
        strike: Decimal.new("200"),
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
               type: :call,
               strike: Decimal.new("200"),
               expiration: ~D[2023-01-01],
               contracts: Decimal.new("4"),
               investment: Decimal.new("480.20")
             }
           ]
  end

  test "selling premium" do
    order = %Order{
      type: :sell,
      instrument: :option,
      quantity: Decimal.new("2"),
      price: Decimal.new("1.7"),
      option: %Option{
        type: :put,
        strike: Decimal.new("250"),
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
               type: :put,
               strike: Decimal.new("250"),
               expiration: ~D[2023-01-01],
               contracts: Decimal.new("4"),
               investment: Decimal.new("-19.60")
             }
           ]
  end
end

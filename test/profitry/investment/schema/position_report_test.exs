defmodule Profitry.Investment.Schema.PositionReportTest do
  use ExUnit.Case, async: true

  alias Profitry.Investment.Schema.PositionReport

  @position_report %PositionReport{
    id: 1234,
    investment: Decimal.new(1800),
    delisted?: false,
    delisting_payout: Decimal.new(0),
    shares: Decimal.new(32),
    cost_basis: Decimal.new("30.2"),
    price: Decimal.new("51.4"),
    fees: Decimal.new("10.5"),
    value: Decimal.new("4532.32"),
    profit: Decimal.new("1234.32")
  }

  describe "position report" do
    test "calculates cost basis" do
      report = PositionReport.calculate_cost_basis(@position_report, true)

      assert Decimal.compare(report.cost_basis, "56.25") === :eq
    end

    test "cost basis is 0 with no shares" do
      report = PositionReport.calculate_cost_basis(@position_report, false)
      assert Decimal.compare(report.cost_basis, 0) === :eq
    end

    test "calculate value" do
      price = Decimal.new("182.37")
      report = PositionReport.calculate_value(@position_report, price)

      assert Decimal.compare(report.value, "5835.84") === :eq
    end

    test "value is 0 with no price" do
      report = PositionReport.calculate_value(@position_report, nil)

      assert Decimal.compare(report.value, 0) === :eq
    end

    test "calculates value for delisted stock with quote" do
      price = Decimal.new("100.00")
      report = %PositionReport{shares: Decimal.new(32), delisted?: true}

      result = PositionReport.calculate_value(report, price)
      assert Decimal.compare(result.value, 0) === :eq
    end

    test "calculates profit" do
      price = Decimal.new("182.37")
      report = PositionReport.calculate_profit(@position_report, price)

      assert Decimal.compare(report.profit, "4035.84") === :eq
      assert report.price === price
    end

    test "profit is 0 with no price" do
      report =
        PositionReport.calculate_profit(
          %PositionReport{
            investment: Decimal.new(1800),
            shares: Decimal.new(32)
          },
          nil
        )

      assert Decimal.compare(report.profit, 0) === :eq
      assert report.price === report.profit
    end

    test "calculates profit for delisted stock with no quote" do
      report = %PositionReport{
        investment: Decimal.new(1800),
        shares: Decimal.new(32),
        delisted?: true,
        delisting_payout: Decimal.new("0.10")
      }

      result = PositionReport.calculate_profit(report, nil)

      # Profit = -investment + (shares * payout) = -1800 + (32 * 0.10) = -1796.8
      assert Decimal.compare(result.profit, Decimal.new("-1796.8")) === :eq
    end

    test "calculates profit for delisted stock with quote (ignores quote)" do
      price = Decimal.new("100.00")

      report = %PositionReport{
        investment: Decimal.new(1800),
        shares: Decimal.new(32),
        delisted?: true,
        delisting_payout: Decimal.new("0.10")
      }

      result = PositionReport.calculate_profit(report, price)

      assert Decimal.compare(result.profit, Decimal.new("-1796.8")) === :eq
      assert result.price === price
    end

    test "calculates profit for delisted stock with zero payout and no quote" do
      report = %PositionReport{
        investment: Decimal.new(1800),
        shares: Decimal.new(32),
        delisted?: true,
        delisting_payout: Decimal.new(0)
      }

      result = PositionReport.calculate_profit(report, nil)

      # Profit = -investment + (shares * 0) = -1800 + 0 = -1800
      assert Decimal.compare(result.profit, Decimal.new("-1800")) === :eq
    end

    test "calculates profit for delisted stock with zero payout and quote" do
      price = Decimal.new("100.00")

      report = %PositionReport{
        investment: Decimal.new(1800),
        shares: Decimal.new(32),
        delisted?: true,
        delisting_payout: Decimal.new(0)
      }

      result = PositionReport.calculate_profit(report, price)

      assert Decimal.compare(result.profit, Decimal.new("-1800")) === :eq
      assert result.price === price
    end
  end
end

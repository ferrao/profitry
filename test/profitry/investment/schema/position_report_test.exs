defmodule Profitry.Investment.Schema.PositionReportTest do
  use ExUnit.Case

  alias Profitry.Investment.Schema.PositionReport

  @position_report %PositionReport{
    investment: Decimal.new(1800),
    shares: Decimal.new(32)
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

    test "calculates profit" do
      price = Decimal.new("182.37")
      report = PositionReport.calculate_profit(@position_report, price)

      assert Decimal.compare(report.profit, "4035.84") === :eq
      assert report.price === price
    end

    test "profit is 0 with no price" do
      report = PositionReport.calculate_profit(@position_report, nil)

      assert Decimal.compare(report.profit, 0) === :eq
      assert report.price === report.profit
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
  end
end

defmodule Profitry.Investment.PositionTotalsTest do
  use ExUnit.Case, async: true

  alias Profitry.Investment.Schema.{PositionReport, PositionTotals}

  describe "position totals" do
    test "creates totals for a portfolio with no positions" do
      totals = PositionTotals.make_totals([])

      assert %PositionTotals{} = totals
      assert totals.value === Decimal.new(0)
      assert totals.profit === Decimal.new(0)
      assert totals.investment === Decimal.new(0)
    end

    test "creates totals for a portfolio with a single position" do
      report = %PositionReport{
        value: Decimal.new("11.2"),
        profit: Decimal.new("-2.0"),
        investment: Decimal.new("13.2")
      }

      totals = PositionTotals.make_totals([report])

      assert totals.value === report.value
      assert totals.profit === report.profit
      assert totals.investment === report.investment
    end

    test "creates totals for a portfolio with multiple positions" do
      reports = [
        %PositionReport{
          value: Decimal.new("11.2"),
          profit: Decimal.new("1.3"),
          investment: Decimal.new("2.0")
        },
        %PositionReport{
          value: Decimal.new("3"),
          profit: Decimal.new("-10.5"),
          investment: Decimal.new("-3.2")
        },
        %PositionReport{
          value: Decimal.new("4.6"),
          profit: Decimal.new("3"),
          investment: Decimal.new("1.7")
        }
      ]

      totals = PositionTotals.make_totals(reports)

      assert totals.value === Decimal.new("18.8")
      assert totals.profit === Decimal.new("-6.2")
      assert totals.investment === Decimal.new("0.5")
    end
  end
end

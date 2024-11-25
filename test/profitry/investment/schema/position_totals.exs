defmodule Profitry.Investment.PositionTotalsTest do
  use ExUnit.Case

  alias Profitry.Investment.Schema.{PositionReport, PositionTotals}

  describe "position totals" do
    test "creates totals for a portfolio with no positions" do
      totals = PositionTotals.make_totals([])

      assert %PositionTotals{} = totals
      assert totals.value === Decimal.new(0)
      assert totals.profit === Decimal.new(0)
    end

    test "creates totals for a portfolio with a single position" do
      report = %PositionReport{value: Decimal.new("11"), profit: Decimal.new("1")}
      totals = PositionTotals.make_totals([report])

      assert totals.value === report.value
      assert totals.profit === report.profit
    end

    test "creates totals for a portfolio with multiple positions" do
      reports = [
        %PositionReport{value: Decimal.new("11.2"), profit: Decimal.new("1.3")},
        %PositionReport{value: Decimal.new("3"), profit: Decimal.new("-10.5")},
        %PositionReport{value: Decimal.new("4.6"), profit: Decimal.new("3")}
      ]

      totals = PositionTotals.make_totals(reports)

      assert totals.value === Decimal.new("18.8")
      assert totals.profit === Decimal.new("-6.2")
    end
  end
end

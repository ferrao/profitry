defmodule ProfitryApp.Investment.TotalsTest do
  use ExUnit.Case

  alias ProfitryApp.Investment.{Report, Totals}

  describe "positions totals" do
    test "calculates total value and profit of a set of positions" do
      reports = [
        %Report{value: Decimal.new("123.34"), profit: Decimal.new("-10.1")},
        %Report{value: Decimal.new("321.25"), profit: Decimal.new("20.2")},
        %Report{value: Decimal.new("213.91"), profit: Decimal.new("-0.12")}
      ]

      %Totals{value: value, profit: profit} = Totals.make_totals(reports)

      assert value == "658.50"
      assert profit == "9.98"
    end
  end
end

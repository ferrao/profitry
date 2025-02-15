defmodule Profitry.Investment.Schema.OptionsReportTest do
  use ExUnit.Case, async: true

  alias Profitry.Investment.Schema.OptionsReport

  @report1 %OptionsReport{
    type: :call,
    strike: Decimal.new("10"),
    contracts: Decimal.new("3"),
    investment: Decimal.new("320.40"),
    expiration: ~D[2023-01-01]
  }

  @report2 %OptionsReport{
    @report1
    | type: :put,
      strike: Decimal.add(@report1.strike, 1),
      contracts: Decimal.new("6"),
      expiration: Date.add(@report1.expiration, 10),
      investment: Decimal.new("203.20")
  }

  describe "options report" do
    test "updates an empty list with an options report" do
      [report] = OptionsReport.update_reports([], @report1)

      assert report == @report1
    end

    test "updates a list with an options report for the same contract" do
      [report | rest] = OptionsReport.update_reports([@report1, @report2], @report1)

      assert report.contracts === Decimal.mult(2, @report1.contracts)
      assert report.type === @report1.type
      assert report.expiration === @report1.expiration
      assert report.strike === @report1.strike

      assert report.investment === Decimal.mult(2, @report1.investment)
      assert rest === [@report2]
    end

    test "updates a list with an option report for a dfferent contract type" do
      [report1 | [report2]] =
        OptionsReport.update_reports([@report1], %{@report1 | type: @report2.type})

      assert report1 === @report1
      assert report2.type === @report2.type
      assert report2.contracts === @report1.contracts
      assert report2.expiration === @report1.expiration
      assert report2.strike === @report1.strike
      assert report2.investment === @report1.investment
    end

    test "updates a list with an option report for a contract with a diferent strike" do
      [report1 | [report2]] =
        OptionsReport.update_reports([@report1], %{@report1 | strike: @report2.strike})

      assert report1 === @report1
      assert report2.type === @report1.type
      assert report2.contracts === @report1.contracts
      assert report2.expiration === @report1.expiration
      assert report2.strike === @report2.strike
      assert report2.investment === @report1.investment
    end

    test "updates a list with an option report for a contract with a diferent expiration date" do
      [report1 | [report2]] =
        OptionsReport.update_reports([@report1], %{@report1 | expiration: @report2.expiration})

      assert report1 === @report1
      assert report2.type === @report1.type
      assert report2.contracts === @report1.contracts
      assert report2.strike === @report1.strike
      assert report2.investment === @report1.investment
      assert report2.expiration === @report2.expiration
    end
  end
end

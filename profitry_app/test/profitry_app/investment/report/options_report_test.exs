defmodule ProfitryApp.Investment.Report.OptionsReportTest do
  use ExUnit.Case

  alias ProfitryApp.Exchanges.Quote
  alias ProfitryApp.Investment.Report.OptionsReport

  @report %OptionsReport{
    strike: 10,
    contracts: 3,
    expiration: ~D[2023-01-01]
  }

  describe "options report value" do
    test "options report value is 0 when quote is not available" do
      %{value: value} = OptionsReport.calculate_value(@report, nil)

      assert value == 0
    end

    test "options report value reflects quote price" do
      %{value: value} =
        OptionsReport.calculate_value(
          @report,
          %Quote{
            ticker: "TSLA",
            price: "254.11"
          }
        )

      assert Decimal.compare(value, Decimal.new("76233")) == :eq
    end
  end

  describe "options report list" do
    test "updates an empty list with an option report" do
      [report] = OptionsReport.update_reports([], @report)

      assert report == @report
    end

    test "updates a list with an option report for the same contract" do
      [report | rest] = OptionsReport.update_reports([@report], @report)

      assert report.contracts == 2 * @report.contracts
      assert report.expiration == @report.expiration
      assert report.strike == 10
      assert rest == []
    end

    test "updates a list with an option report for a contract with a diferent strike" do
      [report1 | [report2]] =
        OptionsReport.update_reports([@report], %OptionsReport{
          @report
          | strike: @report.strike + 1
        })

      assert report1 == @report
      assert report2.contracts == @report.contracts
      assert report2.expiration == @report.expiration
      assert report2.strike == @report.strike + 1
    end

    test "updates a list with an option report for a contract with a diferent expiration date" do
      [report1 | [report2]] =
        OptionsReport.update_reports([@report], %OptionsReport{
          @report
          | expiration: Date.add(@report.expiration, 10)
        })

      assert report1 == @report
      assert report2.contracts == @report.contracts
      assert report2.strike == @report.strike
      assert report2.expiration == Date.add(@report.expiration, 10)
    end
  end
end

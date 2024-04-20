defmodule Profitry.Investment.Reports do
  @moduledoc """

  Generate a report on a portfolio position

  """

  alias Profitry.Investment.Schema.OptionsReport
  alias Profitry.Investment.Schema.{Position, PositionReport, Order, Option}
  alias Profitry.Exchanges.Schema.Quote

  @shares_per_contract 100

  @doc """

  Creates a report on a portfolio position

  """
  @spec make_report(Position.t(), Quote.t()) :: Report.t()
  def make_report(%Position{ticker: ticker, orders: orders}, _quote \\ nil) do
    report = %PositionReport{ticker: ticker}

    report =
      Enum.reduce(orders, report, fn order, report ->
        calculate_order(report, order)
      end)

    report
  end

  # buy stock 
  def calculate_order(report, %Order{
        type: :buy,
        instrument: :stock,
        quantity: quantity,
        price: price
      }) do
    %PositionReport{
      report
      | investment: Decimal.add(report.investment, Decimal.mult(quantity, price)),
        shares: Decimal.add(report.shares, quantity)
    }
  end

  # sell stock 
  def calculate_order(report, %Order{
        type: :sell,
        instrument: :stock,
        quantity: quantity,
        price: price
      }) do
    %PositionReport{
      report
      | investment: Decimal.sub(report.investment, Decimal.mult(quantity, price)),
        shares: Decimal.sub(report.shares, quantity)
    }
  end

  # buy premium
  def calculate_order(report, %Order{
        type: :buy,
        instrument: :option,
        quantity: quantity,
        price: price,
        option: %Option{
          strike: strike,
          expiration: expiration
        }
      }) do
    %PositionReport{
      report
      | investment:
          Decimal.add(
            report.investment,
            quantity |> Decimal.mult(price) |> Decimal.mult(@shares_per_contract)
          ),
        long_options:
          OptionsReport.update_reports(report.long_options, %OptionsReport{
            strike: strike,
            expiration: expiration,
            contracts: quantity,
            value: price
          })
    }
  end

  # sell premium
  def calculate_order(report, %Order{
        type: :sell,
        instrument: :option,
        quantity: quantity,
        price: price,
        option: %Option{
          strike: strike,
          expiration: expiration
        }
      }) do
    %PositionReport{
      report
      | investment:
          Decimal.sub(
            report.investment,
            quantity |> Decimal.mult(price) |> Decimal.mult(@shares_per_contract)
          ),
        short_options:
          OptionsReport.update_reports(report.short_options, %OptionsReport{
            strike: strike,
            expiration: expiration,
            contracts: quantity,
            value: price
          })
    }
  end
end

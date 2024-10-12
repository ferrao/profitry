defmodule Profitry.Investment.Reports do
  @moduledoc """

    Generate a report on a portfolio position

  """

  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Investment.Schema.OptionsReport
  alias Profitry.Investment.Schema.{Position, PositionReport, Order, Option}

  import Profitry.Investment.Schema.Option, only: [option_value: 1]

  @doc """

  Creates a report on a portfolio position

  """
  @spec make_report(Position.t(), Quote.t()) :: PositionReport.t()
  def make_report(%Position{ticker: ticker, orders: orders}, quote \\ %Quote{}) do
    report = %PositionReport{ticker: ticker}

    report =
      Enum.reduce(orders, report, fn order, report ->
        calculate_order(report, order)
      end)

    has_shares = Decimal.gt?(report.shares, 0)

    report
    |> PositionReport.calculate_cost_basis(has_shares)
    |> PositionReport.calculate_profit(quote.price)
    |> PositionReport.calculate_value(quote.price)
    |> Map.put(:price, quote.price || Decimal.new(0))
    |> Map.put(:ticker, ticker)
  end

  # buy stock
  @spec calculate_order(PositionReport.t(), Order.t()) :: PositionReport.t()
  def calculate_order(report, %Order{
        type: :buy,
        instrument: :stock,
        quantity: quantity,
        price: price
      }) do
    %PositionReport{
      report
      | investment: Decimal.add(report.investment, stock_investment(quantity, price)),
        shares: Decimal.add(report.shares, quantity)
    }
  end

  # sell stock
  @spec calculate_order(PositionReport.t(), Order.t()) :: PositionReport.t()
  def calculate_order(report, %Order{
        type: :sell,
        instrument: :stock,
        quantity: quantity,
        price: price
      }) do
    %PositionReport{
      report
      | investment: Decimal.sub(report.investment, stock_investment(quantity, price)),
        shares: Decimal.sub(report.shares, quantity)
    }
  end

  # buy premium
  @spec calculate_order(PositionReport.t(), Order.t()) :: PositionReport.t()
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
      | investment: Decimal.add(report.investment, option_investment(quantity, price)),
        long_options:
          OptionsReport.update_reports(report.long_options, %OptionsReport{
            strike: strike,
            expiration: expiration,
            contracts: quantity,
            investment: option_investment(quantity, price)
          })
    }
  end

  # sell premium
  @spec calculate_order(PositionReport.t(), Order.t()) :: PositionReport.t()
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
      | investment: Decimal.sub(report.investment, option_investment(quantity, price)),
        short_options:
          OptionsReport.update_reports(report.short_options, %OptionsReport{
            strike: strike,
            expiration: expiration,
            contracts: quantity,
            investment: Decimal.mult(option_investment(quantity, price), -1)
          })
    }
  end

  @spec stock_investment(Decimal.t(), Decimal.t()) :: Decimal.t()
  defp stock_investment(quantity, price), do: Decimal.mult(quantity, price)

  @spec stock_investment(Decimal.t(), Decimal.t()) :: Decimal.t()
  defp option_investment(quantity, price), do: Decimal.mult(quantity, option_value(price))
end

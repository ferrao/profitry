defmodule ProfitryApp.Investment.Report.PositionReport do
  @moduledoc """

  Generate a report on a portfolio position

  """
  import ProfitryApp.Utils.Ecto, only: [decimal_to_string: 1]

  alias ProfitryApp.Investment.{Position, Order, Option, Report}
  alias ProfitryApp.Investment.Report.OptionsReport
  alias ProfitryApp.Exchanges.Quote

  @doc """

  Creates a report on a portfolio position

  """
  def make_report(%Position{id: id, ticker: ticker, orders: orders}, quote \\ nil) do
    report = %Report{position_id: id, ticker: ticker}

    report =
      Enum.reduce(orders, report, fn order, report ->
        calculate_order(report, order)
      end)

    has_shares = Decimal.gt?(report.shares, 0)

    report
    |> calculate_cost_basis(has_shares)
    |> calculate_profit(quote)
    |> calculate_value(quote)
    |> stringify_decimals
    |> Map.put(:ticker, ticker)
  end

  @doc """

    Calculates impact of an order on an existing position

  """
  # buying shares
  def calculate_order(report, %Order{
        type: :buy,
        instrument: :stock,
        quantity: quantity,
        price: price
      }) do
    %Report{
      report
      | investment: Decimal.add(report.investment, Decimal.mult(quantity, price)),
        shares: Decimal.add(report.shares, quantity)
    }
  end

  # selling shares
  def calculate_order(report, %Order{
        type: :sell,
        instrument: :stock,
        quantity: quantity,
        price: price
      }) do
    %Report{
      report
      | investment: Decimal.sub(report.investment, Decimal.mult(quantity, price)),
        shares: Decimal.sub(report.shares, quantity)
    }
  end

  # buying premium
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
    %Report{
      report
      | investment:
          Decimal.add(
            report.investment,
            quantity
            |> Decimal.mult(price)
            |> Decimal.mult(100)
          ),
        long_options:
          OptionsReport.update_reports(report.long_options, %OptionsReport{
            contracts: quantity,
            strike: strike,
            expiration: expiration,
            value: 0
          })
    }
  end

  # selling premium
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
    %Report{
      report
      | investment:
          Decimal.sub(
            report.investment,
            quantity
            |> Decimal.mult(price)
            |> Decimal.mult(100)
          ),
        short_options:
          OptionsReport.update_reports(report.short_options, %OptionsReport{
            contracts: quantity,
            strike: strike,
            expiration: expiration,
            value: 0
          })
    }
  end

  @doc """

  Calculates the cost basis for a position report

  """
  # with no shares
  def calculate_cost_basis(report, _has_shares = false) do
    Map.put(report, :cost_basis, "0.00")
  end

  # with shares
  def calculate_cost_basis(report, _has_shares) do
    Map.put(report, :cost_basis, Decimal.div(report.investment, report.shares))
  end

  @doc """

  Calculates the profit on a position report

  """
  # with no quote
  def calculate_profit(report, nil) do
    Map.put(report, :profit, 0)
  end

  # with a quote
  def calculate_profit(report, quote = %Quote{}) do
    Map.put(report, :price, quote.price)
    |> Map.put(
      :profit,
      Decimal.mult(report.shares, quote.price) |> Decimal.sub(report.investment)
    )
  end

  @doc """

  Calculates the value of a position report

  # TODO: calculate_value needs to include OptionsReport.calculate_value call
  # which implies we need quotes for option contracts as well 
  """
  # with no quote
  def calculate_value(report, nil) do
    Map.put(report, :value, 0)
  end

  # with quote
  def calculate_value(report, quote = %Quote{}) do
    Map.put(report, :value, Decimal.mult(report.shares, quote.price))
  end

  defp stringify_decimals(report) do
    %Report{
      report
      | investment: decimal_to_string(report.investment),
        shares: decimal_to_string(report.shares),
        cost_basis: decimal_to_string(report.cost_basis),
        profit: decimal_to_string(report.profit)
    }
  end
end

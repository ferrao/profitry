defmodule ProfitryApp.Core.Report do
  use Ecto.Schema

  alias ProfitryApp.Core.{Position, Order, Report}

  schema "reports" do
    field :ticker, :string
    field :investment, :decimal
    field :shares, :decimal
    field :cost_basis, :decimal
  end

  def make_report(%Position{id: id, ticker: ticker, orders: orders}) do
    report = %Report{
      id: id,
      ticker: ticker,
      investment: 0,
      shares: 0,
      cost_basis: 0
    }

    report = Enum.reduce(orders, report, fn order, report -> calculate_order(report, order) end)

    has_shares = Decimal.gt?(report.shares, 0)

    report
    |> calculate_cost_basis(has_shares)
    |> stringify_decimals
    |> Map.put(:ticker, ticker)
  end

  # calculates impact of buying shares on an existing position
  defp calculate_order(report, %Order{
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

  # calculates impact of selling shares on an existing position
  defp calculate_order(report, %Order{
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

  # calculates impact of buying premium on an existing position
  defp calculate_order(report, %Order{
         type: :buy,
         instrument: :option,
         quantity: quantity,
         price: price
       }) do
    %Report{
      report
      | investment:
          Decimal.add(
            report.investment,
            quantity
            |> Decimal.mult(price)
            |> Decimal.mult(100)
          )
    }
  end

  # calculates impact of selling premium on an existing position
  defp calculate_order(report, %Order{
         type: :sell,
         instrument: :option,
         quantity: quantity,
         price: price
       }) do
    %Report{
      report
      | investment:
          Decimal.sub(
            report.investment,
            quantity
            |> Decimal.mult(price)
            |> Decimal.mult(100)
          )
    }
  end

  # calculates the cost basis for a position report with no shares
  defp calculate_cost_basis(report, _has_shares = false) do
    Map.put(report, :cost_basis, "0.00")
  end

  # calculates the cost basis for a position report with shares
  defp calculate_cost_basis(report, _has_shares) do
    Map.put(report, :cost_basis, Decimal.div(report.investment, report.shares))
  end

  defp stringify_decimals(report) do
    %Report{
      report
      | investment: decimal_to_string(report.investment),
        shares: decimal_to_string(report.shares),
        cost_basis: decimal_to_string(report.cost_basis)
    }
  end

  defp decimal_to_string(decimal) do
    decimal
    |> Decimal.round(2)
    |> Decimal.to_string()
  end
end

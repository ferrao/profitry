defmodule Profitry.Report do
  defstruct(
    ticker: nil,
    investment: 0,
    shares: 0,
    cost_basis: 0
  )

  def make_report(%{orders: orders, ticker: ticker}) do
    Enum.reduce(orders, %{investment: 0, shares: 0, cost_basis: 0}, fn order, report ->
      add_order(report, order)
    end)
    |> calculate_cost_basis
    |> stringify_decimals
    |> Map.put(:ticker, ticker)
  end

  defp add_order(report, order = %{type: :buy}) do
    %{
      investment: Decimal.add(report.investment, Decimal.mult(order.quantity, order.price)),
      shares: Decimal.add(report.shares, order.quantity)
    }
  end

  defp add_order(report, order = %{type: :sell}) do
    %{
      investment: Decimal.sub(report.investment, Decimal.mult(order.quantity, order.price)),
      shares: Decimal.sub(report.shares, order.quantity)
    }
  end

  defp calculate_cost_basis(report) do
    Map.put(report, :cost_basis, Decimal.div(report.investment, report.shares))
  end

  defp stringify_decimals(report) do
    %{
      report
      | investment: decimal_to_string(report.investment),
        shares: decimal_to_string(report.shares),
        cost_basis: decimal_to_string(report.cost_basis)
    }
  end

  defp decimal_to_string(decimal), do: decimal |> Decimal.round(2) |> Decimal.to_string()
end

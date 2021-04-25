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
    |> Map.put(:ticker, ticker)
  end

  defp add_order(report, order = %{type: :buy}) do
    %{
      investment: report.investment + order.quantity * order.price,
      shares: report.shares + order.quantity
    }
  end

  defp add_order(report, order = %{type: :sell}) do
    %{
      investment: report.investment - order.quantity * order.price,
      shares: report.shares - order.quantity
    }
  end

  defp calculate_cost_basis(report) do
    Map.put(report, :cost_basis, (report.investment / report.shares) |> Float.round(2))
  end
end

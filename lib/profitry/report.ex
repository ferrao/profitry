defmodule Profitry.Report do
  defstruct(
    ticker: nil,
    investment: 0,
    shares: 0,
    cost_basis: 0
  )

  # Creates a position report
  def make_report(%{orders: orders, ticker: ticker}) do
    Enum.reduce(orders, %{investment: 0, shares: 0, cost_basis: 0}, fn order, report ->
      calculate_order(report, order)
      # |> IO.inspect()
    end)
    |> calculate_cost_basis
    |> stringify_decimals
    |> Map.put(:ticker, ticker)
  end

  # calculates impact of buying shares on an existing position
  defp calculate_order(report, %{type: :buy, quantity: quantity, price: price}) do
    %{
      investment: Decimal.add(report.investment, Decimal.mult(quantity, price)),
      shares: Decimal.add(report.shares, quantity)
    }
  end

  # calculates impact of selling shares on an existing position
  defp calculate_order(report, %{type: :sell, quantity: quantity, price: price}) do
    %{
      investment: Decimal.sub(report.investment, Decimal.mult(quantity, price)),
      shares: Decimal.sub(report.shares, quantity)
    }
  end

  # calculates impact of buying premium on an existing position
  defp calculate_order(report, %{type: :buy, premium: premium}) do
    %{
      report
      | investment: Decimal.add(report.investment, Decimal.mult(premium, 100))
    }
  end

  # calculates impact of selling premium on an existing position
  defp calculate_order(report, %{type: :sell, premium: premium}) do
    %{
      report
      | investment: Decimal.sub(report.investment, Decimal.mult(premium, 100))
    }
  end

  # calculates the cost basis for a position report
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

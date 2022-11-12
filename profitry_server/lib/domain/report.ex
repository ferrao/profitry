defmodule Profitry.Domain.Report do
  alias Profitry.Domain.{Report, Position}

  @type t :: %__MODULE__{
          ticker: String.t(),
          investment: String.t(),
          shares: String.t(),
          cost_basis: String.t()
        }

  defstruct(
    ticker: nil,
    investment: 0,
    shares: 0,
    cost_basis: 0
  )

  # Creates a position report
  @spec make_report(Position.t()) :: Report.t()
  def make_report(%Position{orders: orders, ticker: ticker}) do
    order_calculation =
      Enum.reduce(orders, %{investment: 0, shares: 0, cost_basis: 0}, fn order, report ->
        calculate_order(report, order)
      end)

    has_shares = Decimal.gt?(order_calculation.shares, 0)

    order_calculation
    |> calculate_cost_basis(has_shares)
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
  defp calculate_order(report, %{type: :buy, contracts: contracts, premium: premium}) do
    %{
      report
      | investment:
          Decimal.add(
            report.investment,
            contracts
            |> Decimal.mult(premium)
            |> Decimal.mult(100)
          )
    }
  end

  # calculates impact of selling premium on an existing position
  defp calculate_order(report, %{type: :sell, contracts: contracts, premium: premium}) do
    %{
      report
      | investment:
          Decimal.sub(
            report.investment,
            contracts
            |> Decimal.mult(premium)
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
    %{
      report
      | investment: decimal_to_string(report.investment),
        shares: decimal_to_string(report.shares),
        cost_basis: decimal_to_string(report.cost_basis)
    }
  end

  defp decimal_to_string(decimal), do: decimal |> Decimal.round(2) |> Decimal.to_string()
end

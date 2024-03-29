defmodule ProfitryApp.Investment.Report do
  use Ecto.Schema

  import ProfitryApp.Utils.Ecto, only: [decimal_to_string: 1]

  alias ProfitryApp.Investment.{Position, Order}

  @derive {Phoenix.Param, key: :position_id}
  schema "reports" do
    field :ticker, :string
    field :investment, :decimal
    field :shares, :decimal
    field :cost_basis, :decimal
    field :price, :decimal
    field :value, :decimal
    field :profit, :decimal
    field :position_id, :integer
  end

  def make_report(%Position{id: id, ticker: ticker, orders: orders}, quote \\ nil) do
    report = %__MODULE__{
      position_id: id,
      ticker: ticker,
      investment: 0,
      shares: 0,
      cost_basis: 0,
      price: 0,
      profit: 0
    }

    report = Enum.reduce(orders, report, fn order, report -> calculate_order(report, order) end)

    has_shares = Decimal.gt?(report.shares, 0)

    report
    |> calculate_cost_basis(has_shares)
    |> calculate_profit(quote)
    |> calculate_value(quote)
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
    %__MODULE__{
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
    %__MODULE__{
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
    %__MODULE__{
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
    %__MODULE__{
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

  defp calculate_profit(report, nil) do
    Map.put(report, :profit, 0)
  end

  defp calculate_profit(report, quote) do
    Map.put(report, :price, quote.price)
    |> Map.put(
      :profit,
      Decimal.mult(report.shares, quote.price) |> Decimal.sub(report.investment)
    )
  end

  defp calculate_value(report, nil) do
    Map.put(report, :value, 0)
  end

  defp calculate_value(report, quote) do
    Map.put(report, :value, Decimal.mult(report.shares, quote.price))
  end

  defp stringify_decimals(report) do
    %__MODULE__{
      report
      | investment: decimal_to_string(report.investment),
        shares: decimal_to_string(report.shares),
        cost_basis: decimal_to_string(report.cost_basis),
        profit: decimal_to_string(report.profit)
    }
  end
end

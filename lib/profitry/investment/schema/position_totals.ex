defmodule Profitry.Investment.Schema.PositionTotals do
  @moduledoc """

  Schema representing the total value and profit of a set of positions

  """

  alias Profitry.Investment.Schema.PositionReport

  @type t :: %__MODULE__{
          value: Decimal.t(),
          profit: Decimal.t(),
          investment: Decimal.t(),
          fees: Decimal.t()
        }

  defstruct value: Decimal.new(0),
            profit: Decimal.new(0),
            investment: Decimal.new(0),
            fees: Decimal.new(0)

  @doc """

  Creates the total investment, value and profit for a set of position reports

  """
  @spec make_totals(list(PositionReport.t())) :: t()
  def make_totals(position_reports) do
    initial_total = %__MODULE__{}

    Enum.reduce(position_reports, initial_total, fn pr, acc ->
      %__MODULE__{
        value: Decimal.add(pr.value, acc.value),
        profit: Decimal.add(pr.profit, acc.profit),
        investment: Decimal.add(pr.investment, acc.investment),
        fees: Decimal.add(pr.fees, acc.fees)
      }
    end)
  end

  @spec cast(t()) :: map()
  def cast(%__MODULE__{} = position_totals) do
    %{
      position_totals
      | value: Decimal.to_string(position_totals.value),
        profit: Decimal.to_string(position_totals.profit),
        investment: Decimal.to_string(position_totals.investment),
        fees: Decimal.to_string(position_totals.fees)
    }
  end

  @spec cast(list(t())) :: list(map())
  def cast(positions_totals) when is_list(positions_totals) do
    Enum.map(positions_totals, fn position_total -> cast(position_total) end)
  end
end

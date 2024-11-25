defmodule Profitry.Investment.Schema.PositionTotals do
  @moduledoc """

  Schema representing the total value and profit of a set of positions

  """
  alias Profitry.Investment.Schema.PositionReport

  @type t :: %__MODULE__{
          value: Decimal.t(),
          profit: Decimal.t()
        }

  defstruct value: Decimal.new(0), profit: Decimal.new(0)

  @spec make_totals(list(PositionReport.t())) :: t()
  def make_totals(position_reports) do
    initial_total = %__MODULE__{}

    Enum.reduce(position_reports, initial_total, fn pr, acc ->
      %__MODULE__{
        value: Decimal.add(pr.value, acc.value),
        profit: Decimal.add(pr.profit, acc.profit)
      }
    end)
  end
end

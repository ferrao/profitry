defmodule ProfitryApp.Investment.Totals do
  @moduledoc """

  Schema representing the total value and profit of a portfolio 

  """
  alias ProfitryApp.Investment.Report
  use Ecto.Schema

  import ProfitryApp.Utils.Ecto, only: [decimal_to_string: 1]

  schema "totals" do
    field :value, :decimal
    field :profit, :decimal
  end

  @doc """

  Aggregates the reports of a list of position reports

  """
  def make_totals([%Report{}] = reports) do
    initial_total = %__MODULE__{
      value: 0,
      profit: 0,
      id: 0
    }

    Enum.reduce(reports, initial_total, fn r, acc ->
      %__MODULE__{
        value: Decimal.add(r.value, acc.value),
        profit: Decimal.add(r.profit, acc.profit),
        id: acc.id
      }
    end)
    |> stringify_decimals
  end

  defp stringify_decimals(totals) do
    %__MODULE__{
      totals
      | value: decimal_to_string(totals.value),
        profit: decimal_to_string(totals.profit)
    }
  end
end

defmodule ProfitryApp.Investment.Totals do
  use Ecto.Schema

  import ProfitryApp.Utils.Ecto, only: [decimal_to_string: 1]

  schema "totals" do
    field :value, :decimal
    field :profit, :decimal
  end

  def make_totals(reports) do
    Enum.reduce(reports, fn r, acc ->
      %__MODULE__{
        value: Decimal.add(r.value, acc.value),
        profit: Decimal.add(r.profit, acc.profit),
        id: 0
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

defmodule ProfitryApp.Utils.Ecto do
  def capitalize(changeset, field) do
    case Ecto.Changeset.get_change(changeset, field) do
      nil -> changeset
      value -> Ecto.Changeset.put_change(changeset, field, String.upcase(value))
    end
  end

  def decimal_to_string(decimal) do
    decimal
    |> Decimal.round(2)
    |> Decimal.to_string()
  end
end

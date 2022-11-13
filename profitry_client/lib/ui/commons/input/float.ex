defmodule ProfitryClient.Ui.Commons.Input.Float do
  def render(label, min, max), do: Owl.IO.input(label: label, cast: validator(min, max))

  defp validator(min, max) do
    fn value ->
      cast_input(%{
        value: value,
        min: min,
        max: max
      })
    end
  end

  defp cast_input(%{value: value, min: min, max: max}) do
    Float.parse(value)
    |> cast_input(min, max)
  end

  defp cast_input({value, _}, min, _max) when value < min do
    {:error, "must be greater than or equal to #{min}"}
  end

  defp cast_input({value, _}, _min, max) when value > max do
    {:error, "must be smaller than or equal to #{max}"}
  end

  defp cast_input(:error, _min, _max), do: {:error, "not a number"}

  defp cast_input({value, _}, _min, _max) do
    {:ok, value}
  end
end

defmodule ProfitryClient.Ui.Commons.Input.String do
  @spec render(String.t(), integer(), integer()) :: String.t()
  def render(label, min, max) do
    Owl.IO.input(label: label, cast: validator(min, max))
  end

  defp validator(min, max) do
    fn str ->
      cast_input(%{
        value: str,
        size: String.length(str),
        min: min,
        max: max
      })
    end
  end

  defp cast_input(%{size: size, min: min}) when size < min do
    {:error, "lenght must be greater than or equal to #{min}"}
  end

  defp cast_input(%{size: size, max: max}) when size > max do
    {:error, "lenght must be smaller than or equal to #{max}"}
  end

  defp cast_input(%{value: value}) do
    {:ok, value}
  end
end

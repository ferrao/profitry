defmodule ProfitryClient.Ui.Commons.Input.Integer do
  @spec render(String.t(), integer(), integer()) :: integer()
  def render(label, min, max),
    do: Owl.IO.input(label: label, cast: {:integer, min: min, max: max})
end

defmodule ProfitryClient.Ui.Commons.Select do
  @spec render(list(%{id: atom(), value: String.t()})) :: any()
  def render(options) do
    Owl.IO.select(options, render_as: fn option -> option.value end)
  end
end

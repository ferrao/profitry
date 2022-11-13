defmodule ProfitryClient.Ui.Commons do
  @spec green(String.t()) :: list(String.t())
  def green(string) do
    string
    |> Owl.Data.tag(:green)
    |> Owl.Data.to_ansidata()
  end

  @spec select(list(%{id: atom(), value: String.t()})) :: any()
  def select(options) do
    Owl.IO.select(options, render_as: fn option -> option.value end)
  end
end

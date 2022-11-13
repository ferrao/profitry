defmodule ProfitryClient.Ui.Commons do
  @spec render_option(%{id: atom(), value: String.t()}) :: String.t()
  def render_option(option), do: option.value

  @spec green(String.t()) :: list(String.t())
  def green(string) do
    string
    |> Owl.Data.tag(:green)
    |> Owl.Data.to_ansidata()
  end
end

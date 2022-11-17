defmodule ProfitryClient.Ui.Commons.Colors do
  def green(string), do: string |> color(:green)

  @spec red(String.t()) :: list(String.t())
  def red(string), do: string |> color(:red)

  # colorize a string by wrapping it with the necessary ANSI codes 
  @spec green(String.t()) :: list(String.t())
  defp color(string, color) do
    string
    |> Owl.Data.tag(color)
    |> Owl.Data.to_ansidata()
  end
end

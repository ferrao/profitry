defmodule ProfitryClient.Ui.Commons.Colors do
  # green colorize a string by wrapping it with the necessary ANSI codes 
  @spec green(String.t()) :: list(String.t())
  def green(string) do
    string
    |> Owl.Data.tag(:green)
    |> Owl.Data.to_ansidata()
  end
end

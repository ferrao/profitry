defmodule ProfitryClient.Ui.Commons.Input.File do
  alias ProfitryClient.Ui.Commons.Input

  def render do
    Input.String.render("File Name?", 1, 80)
    |> Path.expand()
  end
end

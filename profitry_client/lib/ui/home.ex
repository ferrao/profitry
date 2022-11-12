defmodule ProfitryClient.Ui.Home do
  @options [
    "List Portfolios",
    "Create a new Portfolio",
    # "Load an existing Portfolio",
    # "Save a Portfolio",
    "Quit"
  ]
  def render(_server) do
    Owl.IO.select(@options)
  end
end

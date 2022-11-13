defmodule ProfitryClient.Ui.Portfolio.Create do
  alias ProfitryClient.Ui.Commons.Input

  def render(server) do
    id =
      Input.String.render("Portfolio ID?", 1, 4)
      |> String.downcase()
      |> String.to_atom()

    name = Input.String.render("Portfolio Name?", 2, 80)
    Profitry.new_portfolio(server, id, name)
  end
end

defmodule ProfitryClient.Ui.Portfolio.Details do
  alias ProfitryClient.Ui.Position

  @spec render(Profitry.portfolio(), Profitry.server()) :: atom()
  def render(portfolio, server) do
    Position.List.render(portfolio, server)
    Position.Create.render(portfolio, server)
  end
end

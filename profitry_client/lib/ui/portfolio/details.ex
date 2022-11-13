defmodule ProfitryClient.Ui.Portfolio.Details do
  alias Profitry.Domain.Portfolio
  alias ProfitryClient.Ui.Position

  @spec render(Portfolio.t(), Profitry.server()) :: atom()
  def render(portfolio, server) do
    Position.List.render(portfolio, server)
  end
end

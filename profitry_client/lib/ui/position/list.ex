defmodule ProfitryClient.Ui.Position.List do
  alias Profitry.Domain.Portfolio
  alias ProfitryClient.Ui.Commons
  alias ProfitryClient.Ui.Position

  @spec render(Portfolio.t(), Profitry.server()) :: atom()
  def render(portfolio, server) do
    portfolio.id
    |> Atom.to_string()
    |> String.upcase()
    |> Kernel.<>(" #{portfolio.name}\n")
    |> Commons.green()
    |> IO.puts()

    portfolio.positions
    |> Enum.map(fn p -> Profitry.report(server, p) end)
    |> IO.puts()

    Position.Create.render(server)
  end
end

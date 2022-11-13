defmodule ProfitryClient.Ui.Position.List do
  alias ProfitryClient.Ui.Commons.Colors

  @spec render(Profitry.portfolio(), Profitry.server()) :: atom()
  def render(portfolio, server) do
    portfolio.id
    |> Atom.to_string()
    |> String.upcase()
    |> Kernel.<>(" #{portfolio.name}\n")
    |> Colors.green()
    |> IO.puts()

    Profitry.report(server, portfolio.id)
    |> Enum.map(&render_ticker/1)
    |> Enum.each(&IO.puts/1)
  end

  defp render_ticker(report) do
    "#{report.ticker} #{report.shares} #{report.cost_basis} #{report.investment}"
  end
end

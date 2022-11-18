defmodule ProfitryClient.Ui.Position.List do
  alias ProfitryClient.Ui.Commons.Colors

  @spec render(Profitry.portfolio(), Profitry.server()) :: atom()
  def render(portfolio, server) do
    portfolio.id
    |> String.upcase()
    |> Kernel.<>(" #{portfolio.name}\n")
    |> Colors.green()
    |> IO.puts()

    table_header = ["Ticker", "Shares", "CostBasis", "Investment"]

    Profitry.report(server, portfolio.id)
    |> Enum.map(&report_as_list/1)
    |> TableRex.quick_render!(table_header)
    |> Colors.blue()
    |> IO.puts()
  end

  defp report_as_list(report),
    do: [report.ticker, report.shares, report.cost_basis, report.investment]
end

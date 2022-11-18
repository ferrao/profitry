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
    |> render_table(table_header)
    |> IO.puts()
  end

  defp render_table([], _), do: ""

  defp render_table(rows, header) do
    rows
    |> TableRex.quick_render!(header)
    |> Colors.blue()
  end

  defp report_as_list(report),
    do: [report.ticker, report.shares, report.cost_basis, report.investment]
end

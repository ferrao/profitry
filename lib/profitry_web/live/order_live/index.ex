defmodule ProfitryWeb.OrderLive.Index do
  use ProfitryWeb, :live_view

  import Number.Currency
  import Profitry.Utils.Date
  import ProfitryWeb.CustomComponents

  alias Profitry.Investment
  alias Profitry.Investment.Schema.PositionReport

  def mount(params, _session, socket) do
    portfolio_id = Map.get(params, "portfolio_id")
    ticker = Map.get(params, "ticker")

    portfolio = Investment.get_portfolio!(portfolio_id)
    position = Investment.find_position(portfolio, ticker)
    orders = Investment.list_orders(position)
    report = Investment.make_report(position)

    socket =
      assign(socket, position: position)
      |> assign(portfolio: portfolio)
      |> assign(report: PositionReport.cast(report))
      |> assign(count: Enum.count(orders))
      |> stream(:orders, orders)

    {:ok, socket}
  end
end

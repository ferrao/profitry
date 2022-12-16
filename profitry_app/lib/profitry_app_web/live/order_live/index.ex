defmodule ProfitryAppWeb.OrderLive.Index do
  use ProfitryAppWeb, :live_view

  alias ProfitryApp.Investment
  alias ProfitryApp.Investment.Order

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user = socket.assigns.current_user
    id = Map.get(params, "id")
    ticker = Map.get(params, "ticker")
    action = socket.assigns.live_action

    portfolio = Investment.get_portfolio!(user, id)
    position = Investment.find_position(portfolio, ticker)
    report = Investment.get_report(position)
    orders = Investment.list_orders(position)

    socket =
      assign(socket, :navigate, ~p"/portfolios/#{id}/positions/#{ticker}/orders")
      |> assign(:report, report)
      |> assign(:orders, orders)
      |> assign(:portfolio, portfolio)
      |> assign(:position, position)

    {:noreply, apply_action(socket, action, params)}
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "List Orders")
    |> assign(:order, nil)
  end

  defp apply_action(socket, :new, params) do
    ticker = Map.get(params, "ticker")

    socket
    |> assign(:page_title, "Add Order")
    |> assign(:ticker, ticker)
    |> assign(:order, %Order{})
  end
end

defmodule ProfitryAppWeb.OrderLive.Index do
  use ProfitryAppWeb, :live_view

  alias ProfitryApp.Investment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user = socket.assigns.current_user
    id = Map.get(params, "id")
    ticker = Map.get(params, "ticker")

    portfolio = Investment.get_portfolio!(user, id)
    position = Investment.find_position(portfolio, ticker)

    socket =
      socket
      |> assign(:portfolio, portfolio)
      |> assign(:position, position)

    {:noreply, socket}
  end
end

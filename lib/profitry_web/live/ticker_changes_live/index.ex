defmodule ProfitryWeb.TickerChangesLive.Index do
  alias Profitry.Investment

  use ProfitryWeb, :live_view

  alias Profitry.Investment.Schema.TickerChange

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    ticker_changes = Investment.list_ticker_changes()

    socket =
      assign(socket, count: Enum.count(ticker_changes))
      |> assign(:ticker_changes, ticker_changes)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ticker Change")
    |> assign(:ticker_change, %TickerChange{})
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "Listing Ticker Changes")
    |> assign(:ticker_change, nil)
  end
end

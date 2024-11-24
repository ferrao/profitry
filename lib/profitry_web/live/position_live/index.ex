defmodule ProfitryWeb.PositionLive.Index do
  alias Profitry.Investment.Schema.Position
  use ProfitryWeb, :live_view

  import Number.Currency

  alias Profitry.Investment
  alias Profitry.Investment.Positions

  @impl true
  def mount(params, _session, socket) do
    id = Map.get(params, "id")
    portfolio = Investment.get_portfolio!(id)

    socket =
      assign(socket, portfolio: portfolio)
      |> stream(:reports, Investment.list_reports!(id))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "Listing Positions")
    |> assign(:position, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Position")
    |> assign(:position, %Position{})
  end

  defp apply_action(socket, :edit, %{"ticker" => ticker}) do
    socket
    |> assign(:page_title, "Edit Position")
    |> assign(:position, Investment.find_position(socket.assigns.portfolio, ticker))
  end

  @impl true
  def handle_info({ProfitryWeb.PositionLive.FormComponent, {:saved, position}}, socket) do
    report =
      position
      |> Positions.preload_orders()
      |> Investment.make_report()

    socket = stream_insert(socket, :reports, report)
    {:noreply, socket}
  end
end

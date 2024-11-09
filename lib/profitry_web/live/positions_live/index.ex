defmodule ProfitryWeb.PositionsLive.Index do
  use ProfitryWeb, :live_view

  alias Profitry.Investment

  @impl true
  def mount(params, _session, socket) do
    id = Map.get(params, "id")
    reports = Investment.list_reports!(id)

    socket = assign(socket, :reports, reports)
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <pre>
    <%= inspect(@reports, pretty: true) %>
    </pre>
    """
  end
end

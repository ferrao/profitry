defmodule ProfitryAppWeb.PortfolioLive.Show do
  use ProfitryAppWeb, :live_view

  alias ProfitryApp.Core

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user = socket.assigns.current_user
    action = socket.assigns.live_action

    {:noreply, apply_action(socket, user, action, params)}
  end

  defp apply_action(socket, user, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:portfolio, Core.get_portfolio!(user, id))
    |> assign(:reports, Core.list_reports!(id))
  end

  defp page_title(:show), do: "Show Portfolio"
  defp page_title(:new), do: "New Position"
end

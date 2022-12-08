defmodule ProfitryAppWeb.PortfolioLive.Show do
  use ProfitryAppWeb, :live_view

  alias ProfitryApp.Core

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    apply_action(socket, socket.assigns.current_user, id)
  end

  defp apply_action(socket, user, id) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:portfolio, Core.get_portfolio!(user, id))}
  end

  defp page_title(:show), do: "Show Portfolio"
  defp page_title(:edit), do: "Edit Portfolio"
end

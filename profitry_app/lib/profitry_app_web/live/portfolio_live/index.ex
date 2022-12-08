defmodule ProfitryAppWeb.PortfolioLive.Index do
  use ProfitryAppWeb, :live_view

  alias ProfitryApp.Core
  alias ProfitryApp.Core.Portfolio

  @impl true
  def mount(_params, _session, socket) do
    portfolios =
      socket.assigns.current_user
      |> Core.list_portfolios()

    {:ok, assign(socket, :portfolios, portfolios)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user = socket.assigns.current_user
    action = socket.assigns.live_action

    {:noreply, apply_action(socket, user, action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    portfolio = Core.get_portfolio!(user, id)

    {:ok, _} = Core.delete_portfolio(portfolio)
    {:noreply, push_navigate(socket, to: ~p"/portfolios")}
  end

  defp apply_action(socket, user, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Portfolio")
    |> assign(:portfolio, Core.get_portfolio!(user, id))
  end

  defp apply_action(socket, _user, :new, _params) do
    socket
    |> assign(:page_title, "New Portfolio")
    |> assign(:portfolio, %Portfolio{})
  end

  defp apply_action(socket, _user, :index, _params) do
    socket
    |> assign(:page_title, "Listing Portfolios")
    |> assign(:portfolio, nil)
  end
end

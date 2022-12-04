defmodule ProfitryAppWeb.PortfolioLive.Index do
  use ProfitryAppWeb, :live_view

  alias ProfitryApp.Core
  alias ProfitryApp.Core.Portfolio

  @impl true
  def mount(_params, _session, socket) do
    portfolios =
      socket.assigns.current_user
      |> list_portfolios()

    {:ok, assign(socket, :portfolios, portfolios)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Portfolio")
    |> assign(:portfolio, Core.get_portfolio!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Portfolio")
    |> assign(:portfolio, %Portfolio{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Portfolios")
    |> assign(:portfolio, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    portfolio = Core.get_portfolio!(id)
    {:ok, _} = Core.delete_portfolio(portfolio)

    {:noreply, assign(socket, :portfolios, list_portfolios())}
  end

  defp list_portfolios, do: Core.list_portfolios()
  defp list_portfolios(user), do: Core.list_portfolios_by_user(user)
end

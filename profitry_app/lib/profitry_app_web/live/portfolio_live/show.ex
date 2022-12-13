defmodule ProfitryAppWeb.PortfolioLive.Show do
  use ProfitryAppWeb, :live_view

  alias ProfitryApp.Repo
  alias ProfitryApp.Utils.Errors
  alias ProfitryApp.Investment
  alias ProfitryApp.Investment.Position

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user = socket.assigns.current_user
    action = socket.assigns.live_action
    id = Map.get(params, "id")

    socket =
      socket
      |> assign(:portfolio, Investment.get_portfolio!(user, id))
      |> assign(:reports, Investment.list_reports!(id))

    {:noreply, apply_action(socket, action)}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "ticker" => ticker}, socket) do
    user = socket.assigns.current_user

    portfolio =
      Investment.get_portfolio!(user, id)
      |> Repo.preload(:positions)

    case Investment.delete_position(portfolio, ticker) do
      {:ok, _position} ->
        {:noreply, push_navigate(socket, to: ~p"/portfolios/#{id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           List.first(Errors.get_message(changeset, :orders))
         )}
    end
  end

  defp apply_action(socket, :show) do
    socket
    |> assign(:page_title, "Show Portfolio")
    |> assign(:position, nil)
  end

  defp apply_action(socket, :new) do
    socket
    |> assign(:page_title, "New Position")
    |> assign(:position, %Position{})
  end

  defp apply_action(socket, :delete) do
    socket
    |> assign(:page_title, "Delete Position")
    |> assign(:position, nil)
  end
end

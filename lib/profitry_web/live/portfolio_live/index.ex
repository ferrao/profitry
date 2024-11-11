defmodule ProfitryWeb.PortfolioLive.Index do
  use ProfitryWeb, :live_view

  alias Profitry.Utils.Errors
  alias Profitry.Investment
  alias Profitry.Investment.Schema.Portfolio

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :portfolios, Investment.list_portfolios())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Portfolio")
    |> assign(:portfolio, Investment.get_portfolio!(id))
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
  def handle_info({ProfitryWeb.PortfolioLive.FormComponent, {:saved, portfolio}}, socket) do
    {:noreply, stream_insert(socket, :portfolios, portfolio)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    portfolio = Investment.get_portfolio!(id)

    case Investment.delete_portfolio(portfolio) do
      {:ok, _portfolio} ->
        {:noreply, stream_delete(socket, :portfolios, portfolio)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           Errors.get_message(changeset, :positions, "Error deleting portfolio.")
           |> List.first()
         )}
    end
  end
end
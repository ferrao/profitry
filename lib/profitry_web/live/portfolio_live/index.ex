defmodule ProfitryWeb.PortfolioLive.Index do
  use ProfitryWeb, :live_view

  alias Profitry.Utils.Errors
  alias Profitry.Investment
  alias Profitry.Investment.Schema.Portfolio

  @impl true
  def mount(_params, _session, socket) do
    portfolios = Investment.list_portfolios()

    socket =
      assign(socket, count: Enum.count(portfolios))
      |> stream(:portfolios, portfolios)

    {:ok, socket}
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

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "Listing Portfolios")
    |> assign(:portfolio, nil)
  end

  @impl true
  def handle_info({ProfitryWeb.PortfolioLive.FormComponent, {:saved, portfolio, count}}, socket) do
    socket =
      assign(socket, :count, count)
      |> stream_insert(:portfolios, portfolio)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    portfolio = Investment.get_portfolio!(id)

    case Investment.delete_portfolio(portfolio) do
      {:ok, _portfolio} ->
        socket =
          assign(socket, :count, socket.assigns.count - 1)
          |> stream_delete(:portfolios, portfolio)

        {:noreply, socket}

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

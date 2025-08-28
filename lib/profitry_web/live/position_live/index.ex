defmodule ProfitryWeb.PositionLive.Index do
  use ProfitryWeb, :live_view

  import ProfitryWeb.CustomComponents
  import Profitry.Utils.Number

  alias Profitry.Utils.Errors
  alias Profitry.Investment
  alias Profitry.Investment.Positions
  alias Profitry.Investment.Schema.{Position, PositionTotals}

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    portfolio_id = Map.get(params, "portf_id")
    portfolio = Investment.get_portfolio!(portfolio_id)
    reports = Investment.list_reports!(portfolio_id)
    totals = PositionTotals.make_totals(reports)

    socket =
      assign(socket, portfolio: portfolio)
      |> assign(totals: totals)
      |> assign(count: Enum.count(reports))
      |> assign(filter_form: to_form(%{}))
      |> stream(:reports, reports)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
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

  defp apply_action(socket, :edit, %{"id" => id}) do
    position = Investment.get_position!(id)
    ticker = Investment.find_ticker(position.ticker)

    socket
    |> assign(:page_title, "Edit Position")
    |> assign(:position, position |> Map.put(:ticker, ticker))
  end

  @impl Phoenix.LiveView
  def handle_info({ProfitryWeb.PositionLive.FormComponent, {:saved, position, count}}, socket) do
    report =
      position
      |> Positions.preload_orders()
      |> Investment.make_report()

    socket =
      assign(socket, :count, count)
      |> stream_insert(:reports, report)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("filter", params, socket) do
    id = socket.assigns.portfolio.id
    filter_param = Map.get(params, "ticker")

    socket =
      socket
      |> assign(:filter_form, to_form(params))
      |> stream(:reports, Investment.list_reports!(id, filter_param), reset: true)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id, "dom_id" => dom_id}, socket) do
    position = Investment.get_position!(id)

    case Investment.delete_position(position) do
      {:ok, _position} ->
        socket =
          assign(socket, count: socket.assigns.count - 1)
          |> stream_delete_by_dom_id(:reports, dom_id)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           Errors.get_message(
             changeset,
             :positions,
             "Error deleting position, delete orders first."
           )
           |> List.first()
         )}
    end
  end
end

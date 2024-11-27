defmodule ProfitryWeb.PositionLive.Index do
  alias Profitry.Investment.Schema.PositionReport
  use ProfitryWeb, :live_view

  import ProfitryWeb.CustomComponents
  import Number.Currency

  alias Profitry.Utils.Errors
  alias Profitry.Investment
  alias Profitry.Investment.Positions
  alias Profitry.Investment.Schema.{Position, PositionTotals, PositionReport}

  @impl true
  def mount(params, _session, socket) do
    id = Map.get(params, "id")
    portfolio = Investment.get_portfolio!(id)
    reports = Investment.list_reports!(id)
    totals = PositionTotals.make_totals(reports)

    socket =
      assign(socket, portfolio: portfolio)
      |> assign(totals: PositionTotals.cast(totals))
      |> stream(:reports, PositionReport.cast(reports))

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

    socket = stream_insert(socket, :reports, PositionReport.cast(report))
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id, "ticker" => ticker, "dom_id" => dom_id}, socket) do
    position =
      Investment.get_portfolio!(id)
      |> Investment.find_position(ticker)

    case Investment.delete_position(position) do
      {:ok, _position} ->
        totals =
          Investment.list_reports!(id)
          |> PositionTotals.make_totals()

        socket = assign(socket, totals: PositionTotals.cast(totals))

        {:noreply, stream_delete_by_dom_id(socket, :reports, dom_id)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           Errors.get_message(changeset, :positions, "Error deleting position.") |> List.first()
         )}
    end
  end
end

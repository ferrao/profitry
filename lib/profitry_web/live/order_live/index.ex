defmodule ProfitryWeb.OrderLive.Index do
  use ProfitryWeb, :live_view

  import Number.Currency
  import Profitry.Utils.Date
  import ProfitryWeb.CustomComponents

  alias Profitry.Utils.Errors
  alias Profitry.Investment
  alias Profitry.Investment.Schema.{PositionReport, Order}

  @impl true
  def mount(params, _session, socket) do
    portfolio_id = Map.get(params, "portfolio_id")
    ticker = Map.get(params, "ticker")

    portfolio = Investment.get_portfolio!(portfolio_id)
    position = Investment.find_position(portfolio, ticker)
    orders = Investment.list_orders(position)
    report = Investment.make_report(position)

    socket =
      assign(socket, position: position)
      |> assign(portfolio: portfolio)
      |> assign(position: position)
      |> assign(report: PositionReport.cast(report))
      |> assign(count: Enum.count(orders))
      |> stream(:orders, orders)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "Listing Orders")
    |> assign(:order, nil)
  end

  defp apply_action(socket, :new, params) do
    ticker = Map.get(params, "ticker")

    socket
    |> assign(:page_title, ticker)
    |> assign(:page_subtitle, "Add Order")
    |> assign(:order, %Order{})
  end

  defp apply_action(socket, :edit, params) do
    ticker = Map.get(params, "ticker")

    socket
    |> assign(:page_title, ticker)
    |> assign(:page_subtitle, "Edit Order")
    |> assign(:order, Investment.get_order(Map.get(params, "id")))
  end

  @impl true
  def handle_info({ProfitryWeb.OrderLive.FormComponent, {:saved, order, count}}, socket) do
    socket =
      assign(socket, :count, count)
      |> stream_insert(:orders, order)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    order = Investment.get_order(id)

    case Investment.delete_order(order) do
      {:ok, _order} ->
        socket =
          assign(socket, :count, socket.assigns.count - 1)
          |> stream_delete(:orders, order)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           Errors.get_message(changeset, :orders, "Error deleting order")
           |> List.first()
         )}
    end
  end
end

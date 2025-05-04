defmodule ProfitryWeb.OrderLive.Index do
  use ProfitryWeb, :live_view

  import Profitry.Utils.Number
  import ProfitryWeb.{CustomComponents, OrdersTable}

  alias Phoenix.LiveView.JS
  alias Profitry.Utils.Errors
  alias Profitry.Investment
  alias Profitry.Investment.Schema.Order

  @impl true
  def mount(params, _session, socket) do
    portfolio_id = Map.get(params, "portfolio_id")
    ticker = Map.get(params, "ticker")

    portfolio = Investment.get_portfolio!(portfolio_id)
    position = Investment.find_position(portfolio, ticker)
    orders = Investment.list_orders_by_insertion(position)
    splits = Investment.find_splits(ticker)
    quote = Profitry.get_quote(ticker)
    report = Investment.make_report(position, quote)

    socket =
      assign(socket, position: position)
      |> assign(portfolio: portfolio)
      |> assign(position: position)
      |> assign(report: report)
      |> assign(splits: calculate_split_indexes(orders, splits))
      |> assign(count: Enum.count(orders))
      |> assign(:option_modal?, false)
      |> stream(
        :orders,
        Enum.with_index(orders, fn order, index ->
          %{id: order.id, index: index, order: order}
        end)
      )

    {:ok, socket}
  end

  defp calculate_split_indexes(orders, splits) do
    Enum.map(splits, fn split ->
      index =
        Enum.find_index(orders, fn order ->
          Date.compare(
            NaiveDateTime.to_date(order.inserted_at),
            split.date
          ) == :lt
        end)

      index = if is_nil(index), do: length(orders), else: index

      %{
        index: index,
        split: split
      }
    end)
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
    |> assign(:instrument, "stock")
  end

  defp apply_action(socket, :edit, params) do
    ticker = Map.get(params, "ticker")
    order = Investment.get_order(Map.get(params, "id"))

    socket
    |> assign(:page_title, ticker)
    |> assign(:page_subtitle, "Edit Order")
    |> assign(:order, order)
    |> assign(:instrument, to_string(order.instrument))
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

  @impl true
  def handle_event("open-option-modal", %{"id" => id}, socket) do
    order = Investment.get_order(id)

    socket =
      if order.option do
        assign(socket, :order, order)
        |> assign(:option_modal?, true)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("close-option-modal", _params, socket) do
    {:noreply, assign(socket, :option_modal?, false)}
  end
end

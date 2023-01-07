defmodule ProfitryAppWeb.OrderLive.Index do
  use ProfitryAppWeb, :live_view

  import ProfitryAppWeb.CustomComponents

  alias ProfitryApp.Utils.Errors
  alias ProfitryApp.Investment
  alias ProfitryApp.Investment.{Order, Totals}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    user = socket.assigns.current_user
    portfolio_id = Map.get(params, "portfolio_id")
    ticker = Map.get(params, "ticker")
    action = socket.assigns.live_action

    portfolio = Investment.get_portfolio!(user, portfolio_id)
    position = Investment.find_position(portfolio, ticker)
    report = Investment.get_report(position)
    orders = Investment.list_orders(position)

    totals =
      portfolio_id
      |> Investment.list_reports!()
      |> Totals.make_totals()

    socket =
      assign(socket, :navigate, ~p"/portfolios/#{portfolio}/positions/#{ticker}/orders")
      |> assign(:portfolio, portfolio)
      |> assign(:position, position)
      |> assign(:report, report)
      |> assign(:totals, totals)
      |> assign(:ticker, ticker)
      |> assign(:orders, orders)

    {:noreply, apply_action(socket, action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    order = Investment.get_order!(id)

    case Investment.delete_order(order) do
      {:ok, _order} ->
        {:noreply, push_navigate(socket, to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           List.first(Errors.get_message(changeset, :orders))
         )}
    end
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "List Orders")
    |> assign(:order, nil)
  end

  defp apply_action(socket, :new, params) do
    ticker = Map.get(params, "ticker")

    socket
    |> assign(:page_title, "Add Order")
    |> assign(:ticker, ticker)
    |> assign(:order, %Order{})
  end

  defp apply_action(socket, :edit, params) do
    socket
    |> assign(:page_title, "Edit Order")
    |> assign(
      :order,
      Enum.find(socket.assigns.orders, &(to_string(&1.id) == Map.get(params, "id")))
    )
  end
end

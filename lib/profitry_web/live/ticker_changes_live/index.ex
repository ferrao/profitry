defmodule ProfitryWeb.TickerChangesLive.Index do
  alias Profitry.Investment

  use ProfitryWeb, :live_view

  alias Profitry.Investment.Schema.TickerChange
  alias Profitry.Utils.Errors

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    ticker_changes = Investment.list_ticker_changes()

    socket =
      assign(socket, count: Enum.count(ticker_changes))
      |> stream(:ticker_changes, ticker_changes)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ticker Change")
    |> assign(:ticker_change, Investment.get_ticker_change!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ticker Change")
    |> assign(:ticker_change, %TickerChange{})
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "Listing Ticker Changes")
    |> assign(:ticker_change, nil)
  end

  @impl Phoenix.LiveView
  def handle_info(
        {ProfitryWeb.TickerChangesLive.FormComponent, {:saved, ticker_change, count}},
        socket
      ) do
    socket =
      assign(socket, :count, count)
      |> stream_insert(:ticker_changes, ticker_change)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    ticker_change = Investment.get_ticker_change!(id)

    case Investment.delete_ticker_change(ticker_change) do
      {:ok, _ticker_change} ->
        socket =
          assign(socket, :count, socket.assigns.count - 1)
          |> stream_delete(:ticker_changes, ticker_change)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           Errors.get_message(changeset, :ticker_changes, "Error deleting ticker change.")
           |> List.first()
         )}
    end
  end
end

defmodule ProfitryWeb.SplitLive.Index do
  alias Profitry.Investment

  use ProfitryWeb, :live_view

  alias Profitry.Utils.Errors
  alias Profitry.Investment
  alias Profitry.Investment.Schema.Split

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    splits = Investment.list_splits()

    socket =
      assign(socket, count: Enum.count(splits))
      |> stream(:splits, splits)

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Stock Split")
    |> assign(:split, Investment.get_split!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Stock Split")
    |> assign(:split, %Split{})
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "Listing Stock Splits")
    |> assign(:split, nil)
  end

  @impl Phoenix.LiveView
  def handle_info({ProfitryWeb.SplitLive.FormComponent, {:saved, split, count}}, socket) do
    socket =
      assign(socket, :count, count)
      |> stream_insert(:splits, split)

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    split = Investment.get_split!(id)

    case Investment.delete_split(split) do
      {:ok, _split} ->
        socket =
          assign(socket, :count, socket.assigns.count - 1)
          |> stream_delete(:splits, split)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           Errors.get_message(changeset, :splits, "Error deleting stock split.")
           |> List.first()
         )}
    end
  end
end

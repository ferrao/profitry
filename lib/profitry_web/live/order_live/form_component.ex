defmodule ProfitryWeb.OrderLive.FormComponent do
  use ProfitryWeb, :live_component

  alias Profitry.Investment

  @impl Phoenix.LiveComponent
  def update(%{order: order} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(Investment.change_order(order)) end)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset = Investment.change_order(socket.assigns.order, order_params)
    instrument = order_params["instrument"] || socket.assigns.instrument

    socket =
      assign(socket, form: to_form(changeset, action: :validate))
      |> assign(:instrument, instrument)

    {:noreply, socket}
  end

  def handle_event("save", %{"order" => order_params}, socket) do
    # Check if the date changed to determine if we need to reset the stream
    date_changed = date_changed?(socket.assigns.order, order_params)
    save_portfolio(socket, socket.assigns.action, order_params, date_changed)
  end

  defp date_changed?(%{inserted_at: nil}, _order_params), do: false

  defp date_changed?(%{inserted_at: original_date}, %{"inserted_at" => new_date_str}) do
    NaiveDateTime.to_iso8601(original_date) != new_date_str
  end

  defp date_changed?(_original_order, _order_params), do: false

  defp save_portfolio(socket, :edit, order_paras, date_changed) do
    case Investment.update_order(socket.assigns.order, order_paras) do
      {:ok, order} ->
        notify_parent({:saved, order, socket.assigns.count, date_changed})

        {:noreply,
         socket
         |> put_flash(:info, "Order updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_portfolio(socket, :new, order_params, _date_changed) do
    case Investment.create_order(socket.assigns.position, order_params) do
      {:ok, order} ->
        notify_parent({:saved, order, socket.assigns.count + 1, false})

        {:noreply,
         socket
         |> put_flash(:info, "Order created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

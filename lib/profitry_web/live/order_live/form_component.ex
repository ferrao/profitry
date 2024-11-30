defmodule ProfitryWeb.OrderLive.FormComponent do
  use ProfitryWeb, :live_component

  alias Profitry.Investment

  @impl true
  def update(%{order: order} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Investment.change_order(order))
     end)}
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset = Investment.change_order(socket.assigns.order, order_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"order" => order_params}, socket) do
    save_portfolio(socket, socket.assigns.action, order_params)
  end

  defp save_portfolio(socket, :edit, order_paras) do
    case Investment.update_order(socket.assigns.order, order_paras) do
      {:ok, order} ->
        notify_parent({:saved, order, socket.assigns.count})

        {:noreply,
         socket
         |> put_flash(:info, "Order updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_portfolio(socket, :new, order_params) do
    case Investment.create_order(socket.assigns.position, order_params) do
      {:ok, order} ->
        notify_parent({:saved, order, socket.assigns.count + 1})

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

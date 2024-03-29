defmodule ProfitryAppWeb.OrderLive.FormComponent do
  use ProfitryAppWeb, :live_component

  alias ProfitryApp.Investment

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Add a new order to the <%= @ticker %> position.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="order-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :type}} type="select" options={["buy", "sell"]} label="Order Type" />
        <.input
          field={{f, :instrument}}
          type="select"
          options={["stock", "option"]}
          label="Instrument"
        />
        <.input field={{f, :quantity}} type="number" step="any" label="Quantity" />
        <.input field={{f, :price}} type="number" step="any" label="Price (USD)" />
        <.input field={{f, :inserted_at}} type="datetime-local" label="Order Date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Order</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{order: order} = assigns, socket) do
    changeset = Investment.change_order(order)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset =
      socket.assigns.order
      |> Investment.change_order(order_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"order" => order_params}, socket) do
    save_order(socket, socket.assigns.action, order_params)
  end

  defp save_order(socket, :edit, order_params) do
    case Investment.update_order(socket.assigns.order, order_params) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_order(socket, :new, order_params) do
    case Investment.create_order(socket.assigns.position, order_params) do
      {:ok, _order} ->
        {:noreply,
         socket
         |> put_flash(:info, "Order added successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

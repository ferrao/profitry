defmodule ProfitryWeb.PositionLive.FormComponent do
  use ProfitryWeb, :live_component

  alias Profitry.Investment

  @impl true
  def update(%{position: position} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:form, fn -> to_form(Investment.change_position(position)) end)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"position" => position_params}, socket) do
    changeset = Investment.change_position(socket.assigns.position, position_params)
    socket = assign(socket, form: to_form(changeset, action: :validate))
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"position" => position_params}, socket) do
    save_position(socket, socket.assigns.action, position_params)
  end

  defp save_position(socket, :edit, position_params) do
    case Investment.update_position(socket.assigns.position, position_params) do
      {:ok, position} ->
        notify_parent({:saved, position, socket.assigns.count})

        {:noreply,
         socket
         |> put_flash(:info, "Position updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_position(socket, :new, position_params) do
    case Investment.create_position(socket.assigns.portfolio, position_params) do
      {:ok, position} ->
        notify_parent({:saved, position, socket.assigns.count + 1})

        {:noreply,
         socket
         |> put_flash(:info, "Position created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

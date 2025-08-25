defmodule ProfitryWeb.SplitLive.FormComponent do
  alias Profitry.Investment
  use ProfitryWeb, :live_component

  @impl Phoenix.LiveComponent
  def update(%{split: split} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Investment.change_split(split))
     end)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"split" => split_params}, socket) do
    changeset = Investment.change_split(socket.assigns.split, split_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"split" => split_params}, socket) do
    save_split(socket, socket.assigns.action, split_params)
  end

  defp save_split(socket, :edit, split_params) do
    case Investment.update_split(socket.assigns.split, split_params) do
      {:ok, split} ->
        notify_parent({:saved, split, socket.assigns.count})

        {:noreply,
         socket
         |> put_flash(:info, "Stock Split updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_split(socket, :new, split_params) do
    case Investment.create_split(split_params) do
      {:ok, split} ->
        notify_parent({:saved, split, socket.assigns.count + 1})

        {:noreply,
         socket
         |> put_flash(:info, "Stock Split created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

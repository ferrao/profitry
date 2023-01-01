defmodule ProfitryAppWeb.PositionLive.FormComponent do
  use ProfitryAppWeb, :live_component

  alias ProfitryApp.Investment

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage positions in your portfolio.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="position-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :ticker}} type="text" label="Stock Ticker" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Position</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{position: position} = assigns, socket) do
    changeset = Investment.change_position(position)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"position" => position_params}, socket) do
    changeset =
      socket.assigns.position
      |> Investment.change_position(position_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"position" => position_params}, socket) do
    save_position(socket, socket.assigns.action, position_params)
  end

  defp save_position(socket, :edit, position_params) do
    case Investment.update_position(socket.assigns.position, position_params) do
      {:ok, _position} ->
        ProfitryApp.Exchanges.broadcast_reset()

        {:noreply,
         socket
         |> put_flash(:info, "Position updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_position(socket, :new, position_params) do
    case Investment.create_position(socket.assigns.portfolio, position_params) do
      {:ok, _position} ->
        ProfitryApp.Exchanges.broadcast_reset()

        {:noreply,
         socket
         |> put_flash(:info, "Position created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

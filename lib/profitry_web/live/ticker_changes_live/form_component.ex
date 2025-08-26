defmodule ProfitryWeb.TickerChangesLive.FormComponent do
  use ProfitryWeb, :live_component

  alias Profitry.Investment

  @impl Phoenix.LiveComponent
  def update(%{ticker_change: ticker_change} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Investment.change_ticker_change(ticker_change))
     end)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"ticker_change" => ticker_change_params}, socket) do
    changeset =
      Investment.change_ticker_change(socket.assigns.ticker_change, ticker_change_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ticker_change" => ticker_change_params}, socket) do
    save_ticker_change(socket, socket.assigns.action, ticker_change_params)
  end

  def save_ticker_change(socket, :new, ticker_change_params) do
    case Investment.create_ticker_change(ticker_change_params) do
      {:ok, ticker_change} ->
        notify_parent({:saved, ticker_change, socket.assigns.count + 1})

        {:noreply,
         socket
         |> put_flash(:info, "Ticker Change created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def save_ticker_change(socket, :edit, ticker_change_params) do
    case Investment.update_ticker_change(socket.assigns.ticker_change, ticker_change_params) do
      {:ok, ticker_change} ->
        notify_parent({:saved, ticker_change, socket.assigns.count})

        {:noreply,
         socket
         |> put_flash(:info, "Ticker Change updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end

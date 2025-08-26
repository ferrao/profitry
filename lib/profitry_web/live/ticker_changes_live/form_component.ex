defmodule ProfitryWeb.TickerChangesLive.FormComponent do
  use ProfitryWeb, :live_component

  alias Profitry.Investment

  @impl Phoenix.LiveComponent
  def update(%{"ticker-change": ticker_change} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Investment.change_ticker_change(ticker_change))
     end)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("validate", %{"ticker_change" => ticker_change_params}, socket) do
    IO.puts("using []")
    IO.inspect(socket.assigns["ticker-change"])
    IO.puts("using Map.get")
    IO.inspect(Map.get(socket.assigns, "ticker-change"))

    # changeset =
    #  Investment.change_ticker_change(socket.assigns["ticker-change"], ticker_change_params)

    # {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end
end

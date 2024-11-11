defmodule ProfitryWeb.PortfolioLive.FormComponent do
  use ProfitryWeb, :live_component

  alias Profitry.Investment

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage portfolios.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="portfolio-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:broker]} label="Broker" />
        <.input field={@form[:description]} label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Portfolio</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{portfolio: portfolio} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Investment.change_portfolio(portfolio))
     end)}
  end

  @impl true
  def handle_event("validate", %{"portfolio" => portfolio_params}, socket) do
    changeset = Investment.change_portfolio(socket.assigns.portfolio, portfolio_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"portfolio" => portfolio_params}, socket) do
    save_portfolio(socket, socket.assigns.action, portfolio_params)
  end

  defp save_portfolio(socket, :edit, portfolio_params) do
    case Investment.update_portfolio(socket.assigns.portfolio, portfolio_params) do
      {:ok, portfolio} ->
        notify_parent({:saved, portfolio})

        {:noreply,
         socket
         |> put_flash(:info, "Portfolio updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_portfolio(socket, :new, portfolio_params) do
    case Investment.create_portfolio(portfolio_params) do
      {:ok, portfolio} ->
        notify_parent({:saved, portfolio})

        {:noreply,
         socket
         |> put_flash(:info, "Portfolio created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
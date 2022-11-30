defmodule ProfitryAppWeb.PortfolioLive.FormComponent do
  use ProfitryAppWeb, :live_component

  alias ProfitryApp.Core

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage portfolio records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="portfolio-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :tikr}} type="text" label="tikr" />
        <.input field={{f, :name}} type="text" label="name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Portfolio</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{portfolio: portfolio} = assigns, socket) do
    changeset = Core.change_portfolio(portfolio)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"portfolio" => portfolio_params}, socket) do
    changeset =
      socket.assigns.portfolio
      |> Core.change_portfolio(portfolio_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"portfolio" => portfolio_params}, socket) do
    save_portfolio(socket, socket.assigns.action, portfolio_params)
  end

  defp save_portfolio(socket, :edit, portfolio_params) do
    case Core.update_portfolio(socket.assigns.portfolio, portfolio_params) do
      {:ok, _portfolio} ->
        {:noreply,
         socket
         |> put_flash(:info, "Portfolio updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_portfolio(socket, :new, portfolio_params) do
    case Core.create_portfolio(portfolio_params) do
      {:ok, _portfolio} ->
        {:noreply,
         socket
         |> put_flash(:info, "Portfolio created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

defmodule ProfitryWeb.OrdersTable do
  @moduledoc """

    Order list UI components

  """

  use ProfitryWeb, :verified_routes
  use Phoenix.Component

  import ProfitryWeb.{CoreComponents, CustomComponents}
  import Profitry.Utils.{Date, Number}

  alias Phoenix.LiveView.JS

  def split_action(assigns) do
    action_icon(%{
      icon: "hero-scissors",
      text: "1:#{assigns.multiple} Split",
      color: "text-green-700"
    })
  end

  def reverse_split_action(assigns) do
    action_icon(%{
      icon: "hero-scissors",
      text: "Rev #{assigns.multiple}:1 Split",
      color: "text-amber-700"
    })
  end

  @doc """

  Renders a position orders table component

  ## Examples

      <.orders_table orders={streams.orders} portfolio={portfolio} position={position} />

  """

  attr :orders, :list, required: true
  attr :splits, :list, required: false
  attr :portfolio, :map, required: true
  attr :position, :map, required: true

  def orders_table(assigns) do
    ~H"""
    <.table id="orders" rows={@orders}>
      <:col :let={{_id, order}} label="Type">
        <%= for split <- @splits do %>
          <%= if split.index === order.index do %>
            <%= if split.reverse do %>
              <.reverse_split_action multiple={split.multiple} />
            <% else %>
              <.split_action multiple={split.multiple} />
            <% end %>
          <% end %>
        <% end %>

        {order.type}
      </:col>
      <:col :let={{_id, order}} label="Instrument">{order.instrument}</:col>
      <:col :let={{_id, order}} label="Quantity">{order.quantity}</:col>
      <:col :let={{_id, order}} label="Price">
        <%= if order.option do %>
          {format_currency(order.price, 100)}
        <% else %>
          {format_currency(order.price)}
        <% end %>
      </:col>

      <:col :let={{_id, order}} label="Contract">
        <%= if order.option do %>
          <.link
            class="option-contract"
            phx-click={JS.push("open-option-modal", value: %{id: order.id})}
          >
            <.option_icon option={order.option} />
          </.link>
        <% else %>
          <.option_icon option={order.option} />
        <% end %>
      </:col>

      <:col :let={{_id, order}} label="Opened">{format_timestamp(order.inserted_at)}</:col>

      <:action :let={{_id, order}}>
        <.link patch={~p"/portfolios/#{@portfolio}/positions/#{@position.id}/orders/#{order}/edit"}>
          Edit
        </.link>
      </:action>
      <:action :let={{_id, order}}>
        <.link phx-click={JS.push("delete", value: %{id: order.id})} data-confirm="Are you sure?">
          Delete
        </.link>
      </:action>
    </.table>
    """
  end
end

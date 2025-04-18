defmodule ProfitryWeb.OrdersTable do
  use ProfitryWeb, :verified_routes
  use Phoenix.Component

  import ProfitryWeb.{CoreComponents, CustomComponents}
  import Profitry.Utils.{Date, Number}

  alias Phoenix.LiveView.JS

  attr :orders, :list, required: true
  attr :splits, :list, required: false
  attr :portfolio, :map, required: true
  attr :position, :map, required: true

  def orders_table(assigns) do
    ~H"""
    <.table id="orders" rows={@orders}>
      <:col :let={{_id, order}} label="Type">{order.type}</:col>
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
        <.link patch={
          ~p"/portfolios/#{@portfolio}/positions/#{@position.ticker}/orders/#{order}/edit"
        }>
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

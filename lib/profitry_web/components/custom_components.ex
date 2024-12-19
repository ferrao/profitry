defmodule ProfitryWeb.CustomComponents do
  @moduledoc """

    Provides custom UI components

  """
  use Phoenix.Component

  import Profitry.Utils.Number
  import ProfitryWeb.CoreComponents

  @doc """

  Renders a profit or loss value.

  ## Examples

      <.profit profit={"12.3"} />
      <.profit profit={"-123.45"} total={"1234"} />

  """

  attr :profit, :string, doc: "the position profit or loss value"
  attr :total, :string, doc: "the optional total portfolio value"

  def profit(%{profit: profit} = assigns) do
    {profit, _} = Float.parse(profit)
    {total, _} = Float.parse(Map.get(assigns, :total, "0"))

    # alert on 1% portfolio loss
    alert_value = abs(total) * 0.01

    color =
      case {profit, alert_value} do
        {profit, _} when profit > 0 ->
          "text-green-700"

        {profit, alert_value} when profit < 0 and abs(profit) < alert_value ->
          "text-yellow-700"

        {_, _} ->
          "text-red-700"
      end

    assigns = assign(assigns, :profit, profit)
    assigns = assign(assigns, :color, color)

    ~H"""
    <%= if @profit != 0 do %>
      <span class={["font-semibold", @color]}>
        {format_currency(@profit)}
      </span>
    <% else %>
      <span class="font-semibold">--</span>
    <% end %>
    """
  end

  @doc """

  Renders an option contract icon

      ## Examples

      <.option_idcon option=%Option{} />

  """
  attr :option, Option, doc: "the option schema"

  def option_icon(%{option: option} = assigns) do
    color =
      cond do
        option === nil -> "text-slate-300"
        Date.after?(Date.utc_today(), option.expiration) -> "text-red-600"
        true -> "text-emerald-600"
      end

    assigns = assign(assigns, :color, color)

    ~H"""
    <div class="flex justify-center">
      <.icon name="hero-document-currency-dollar" class={Enum.join(["h-4 w-4 ", @color])} />
    </div>
    """
  end

  attr :ticker, :string, doc: "the position ticker"
  attr :order, Order, doc: "the order schema"

  def option_data(assigns) do
    ~H"""
    <div>
      <.header>
        {@ticker}
        <:subtitle>
          Options Contract
        </:subtitle>
      </.header>
      <.list text_size="text-lg">
        <:item title="Order Type">{String.capitalize(to_string(@order.type))}</:item>
        <:item title="Quantity">{format_number(@order.quantity)}</:item>
        <:item title="Option Type">{String.capitalize(to_string(@order.option.type))}</:item>
        <:item title="Price">{format_currency(@order.price)}</:item>
        <:item title="Strike Price">{format_currency(@order.option.strike)}</:item>
        <:item title="Expiry Date">{@order.option.expiration}</:item>
      </.list>
    </div>
    """
  end
end

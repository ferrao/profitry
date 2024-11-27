defmodule ProfitryWeb.CustomComponents do
  @moduledoc """

    Provides custom UI components

  """
  require Decimal
  use Phoenix.Component

  import Number.Currency

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
        <%= number_to_currency(@profit) %>
      </span>
    <% else %>
      <span class="font-semibold">--</span>
    <% end %>
    """
  end
end

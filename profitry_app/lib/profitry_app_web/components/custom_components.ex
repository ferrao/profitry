defmodule ProfitryAppWeb.CustomComponents do
  use Phoenix.Component

  import Number.Currency

  def currency(number), do: number_to_currency(number)
  def date(date), do: Calendar.strftime(date, "%d/%m/%Y %H:%M:%S")

  @doc """
  Renders an email pill.

  ## Examples

      <.email user={@current_user} />

  """
  attr :user, :map, doc: "the currently logged in user"
  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def email(assigns) do
    ~H"""
    <%= if @user do %>
      <div class="px-6 py-2">
        <span class="bg-zinc-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">
          <%= render_slot(@inner_block) %>
          <%= @user.email %>
        </span>
      </div>
    <% end %>
    """
  end

  @doc """
  Renders a profit or loss value.

  ## Examples

      <.profit value={"-123.45"} />

  """
  attr :profit, :string, doc: "the position profit or loss value"
  attr :total, :string, doc: "the optional total portfolio value"

  def profit(assigns) do
    {profit, _} = Float.parse(assigns.profit)
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

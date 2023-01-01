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

  def email(assigns) do
    ~H"""
    <%= if @user do %>
      <div class="px-6 py-2">
        <span class="bg-zinc-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">
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
  attr :value, :string, doc: "the profit or loss value"

  def profit(assigns) do
    {value, _} = Float.parse(assigns.value)
    assigns = assign(assigns, :value, value)

    ~H"""
    <%= case @value do %>
      <% value when value > 0 -> %>
        <span class="font-semibold text-green-700">
          <%= number_to_currency(@value) %>
        </span>
      <% value when value < 0 -> %>
        <span class="font-semibold text-red-700">
          <%= number_to_currency(@value) %>
        </span>
      <% value when value == 0 -> %>
        <span class="font-semibold">--</span>
    <% end %>
    """
  end
end

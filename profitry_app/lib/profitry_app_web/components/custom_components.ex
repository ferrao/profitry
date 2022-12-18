defmodule ProfitryAppWeb.CustomComponents do
  use Phoenix.Component

  @doc """
  Renders an email pill.

  ## Examples

      <.email user={@current_user} />

  attr :user, :map, doc: "the currently logged in user"
  """

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

  # def email(assigns),
  #   do: ~H"""
  #
  #   """
end

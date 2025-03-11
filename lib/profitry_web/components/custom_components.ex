defmodule ProfitryWeb.CustomComponents do
  @moduledoc """

    Provides custom UI components

  """
  use Phoenix.Component

  import Profitry.Utils.Number
  import ProfitryWeb.CoreComponents

  alias Profitry.Investment
  alias ElixirLS.LanguageServer.Plugins.Option
  alias Profitry.Investment.Schema.Option

  @doc """

  Renders a profit or loss value.

  ## Examples

      <.profit profit={"12.3"} />
      <.profit profit={"-123.45"} total={"1234"} />

  """

  attr :profit, Decimal, required: true, doc: "the position profit or loss value"
  attr :total, Decimal, default: Decimal.new(0), doc: "the optional total portfolio value"

  def profit(%{profit: profit, total: total} = assigns) do
    # alert on 1% portfolio loss
    alert_value =
      total
      |> Decimal.abs()
      |> Decimal.mult(Decimal.from_float(0.01))
      |> Decimal.to_float()

    color = profit_color(Decimal.to_float(profit), alert_value)
    assigns = assign(assigns, :profit, format_number(profit))
    assigns = assign(assigns, :color, color)

    ~H"""
    <%= if @profit != 0 do %>
      <span class={["font-semibold", @color]}>
        {format_currency(@profit)}
      </span>
    <% else %>
      <span class="font-semibold">
        --
      </span>
    <% end %>
    """
  end

  @spec profit_color(float(), float()) :: String.t()
  defp profit_color(profit, alert_value) do
    case {profit, alert_value} do
      {profit, _} when profit >= 0 ->
        "text-green-700"

      {profit, alert_value} when profit < 0 and abs(profit) < alert_value ->
        "text-yellow-700"

      {_, _} ->
        "text-red-700"
    end
  end

  @doc """

  Renders an option contract icon

      ## Examples

      <.option_icon option=%Option{} />

  """
  attr :option, Option, doc: "the option schema"

  def option_icon(%{option: option} = assigns) do
    color =
      cond do
        option === nil -> "text-slate-300"
        Option.expired?(option) -> "text-red-600"
        true -> "text-emerald-600"
      end

    assigns = assign(assigns, :color, color)

    ~H"""
    <div class="flex justify-center">
      <.icon name="hero-document-currency-dollar" class={Enum.join(["h-4 w-4 ", @color])} />
    </div>
    """
  end

  @doc """

    Renders a position icon

      ## Examples

      <.posiiton_icon report=%PositionReport{}>
        TSLA
      <./position_icon>

  """
  attr :report, :map, required: true, doc: "the position report"

  def position_icon(%{report: report} = assigns) do
    {color, name} =
      cond do
        Investment.position_closed?(report) -> {"text-red-700", "hero-x-circle"}
        true -> {"text-green-700", "hero-play-circle"}
      end

    assigns =
      assigns
      |> assign(:color, color)
      |> assign(:name, name)

    ~H"""
    <div class="flex items-center">
      <.icon name={@name} class={Enum.join(["h-4 w-4 ", @color])} /> &nbsp; {@report.ticker}
    </div>
    """
  end

  attr :ticker, :string, doc: "the position ticker"
  attr :order, Order, doc: "the order schema"

  @doc """

    Renders the option position data

      ## Examples

      <.option_data ticker="TSLA" order={%PositionOrder{}} />

  """
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

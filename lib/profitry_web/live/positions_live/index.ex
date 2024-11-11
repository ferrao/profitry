defmodule ProfitryWeb.PositionsLive.Index do
  use ProfitryWeb, :live_view

  import Number.Currency

  alias Profitry.Investment

  @impl true
  def mount(params, _session, socket) do
    id = Map.get(params, "id")
    portfolio = Investment.get_portfolio!(id)

    socket =
      assign(socket, portfolio: portfolio)
      |> stream(:reports, Investment.list_reports!(id))

    {:ok, socket}
  end
end

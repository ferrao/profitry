defmodule ProfitryClient.Ui.Position.Create do
  alias ProfitryClient.Ui.Commons.Select
  alias ProfitryClient.Ui.Order

  def render(portfolio, server) do
    options = [
      %{id: :create, value: "Add Order"},
      %{id: :back, value: "Go Back"}
    ]

    Select.render(options)
    |> render(portfolio, server)
  end

  def render(%{id: :create}, portfolio, server) do
    ticker =
      Owl.IO.input(label: "Ticker?")
      |> String.upcase()

    order = Order.Create.render()

    Profitry.make_order(server, portfolio.id, ticker, order)

    render(portfolio, server)
  end

  def render(_, _, _server) do
  end
end

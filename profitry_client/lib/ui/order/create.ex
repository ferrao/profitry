defmodule ProfitryClient.Ui.Order.Create do
  alias Profitry.Domain.{OptionsOrder, StockOrder}
  alias ProfitryClient.Ui.Commons.{Select, Input}

  def render() do
    options = [
      %{id: :buy_stock, value: "Buy Stocks"},
      %{id: :sell_stock, value: "Sell Stocks"},
      %{id: :buy_options, value: "Buy Options Contracts"},
      %{id: :sell_options, value: "Sell Options Contracts"}
    ]

    transaction = Select.render(options)

    quantity = Input.Float.render("Quantity?", 0.01, 1000)
    price = Input.Float.render("Price?", 0, 999_999_999)

    order(transaction, quantity, price)
  end

  defp order(%{id: :buy_stock}, quantity, price),
    do: %StockOrder{type: :buy, quantity: quantity, price: price}

  defp order(%{id: :sell_stock}, quantity, price),
    do: %StockOrder{type: :sell, quantity: quantity, price: price}

  defp order(%{id: :buy_options}, quantity, price),
    do: %OptionsOrder{type: :buy, contracts: quantity, premium: price}

  defp order(%{id: :sell_options}, quantity, price),
    do: %OptionsOrder{type: :sell, contracts: quantity, premium: price}
end

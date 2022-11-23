defmodule ProfitryClient.Runtime.Decoder do
  alias Profitry.Domain.{Portfolio, Position, StockOrder, OptionsOrder}

  defimpl Poison.Decoder, for: Portfolio do
    def decode(value, _options) do
      Map.update!(value, :positions, fn positions ->
        Map.new(positions, fn {key, p} -> {key, decode_position(p)} end)
      end)
    end

    defp decode_position(position),
      do: %Position{ticker: position.ticker, orders: position.orders |> Enum.map(&decode_order/1)}

    defp decode_order(order) when is_map_key(order, :quantity),
      do: %StockOrder{
        quantity: order.quantity,
        price: order.price,
        type: String.to_atom(order.type)
      }

    defp decode_order(order) when is_map_key(order, :contracts),
      do: %OptionsOrder{
        contracts: order.contracts,
        premium: order.premium,
        type: String.to_atom(order.type)
      }
  end
end

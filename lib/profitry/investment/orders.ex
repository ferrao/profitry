defmodule Profitry.Investment.Orders do
  import Ecto.Query

  alias Profitry.Repo
  alias Profitry.Investment.Schema.{Position, Order}

  @doc """

  Returns the list of orders for a position.

  ## Examples

      iex> list_orders(position)
      [%Order{}, ...]

  """
  @spec list_orders(Position.t()) :: list(Order.t())
  def list_orders(%Position{} = position) do
    Ecto.assoc(position, :orders)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end

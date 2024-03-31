defmodule Profitry.Investment.Orders do
  import Ecto.Query

  alias Profitry.Repo
  alias Profitry.Investment.Schema.{Position, Order}

  @doc """

  Creates an order on a position

  ## Examples

      iex> create_order(position, %{field: value})
      {:ok, %Order{}}

      iex> create_order(position, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_order(Position.t(), Map.t()) ::
          {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def create_order(position, attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:position, position)
    |> Repo.insert()
  end

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

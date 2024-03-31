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

  @doc """

  Get a single order

  ## Examples

    iex> get_order(123) 
    %Order{}

    iex> get_order(456)
    nil

  """
  @spec get_order(integer()) :: Order.t() | nil
  def get_order(id) do
    Repo.get(Order, id)
  end

  @doc """

  Updates an order

  ## Examples

    iex> update_order(order, %{field: new_value})
    {:ok, %Order{}}

    iex> update_order(order, %{field: bad_value})
    {:error, %Ecto.Changeset{}}

  """
  @spec update_order(Order.t(), Map.t()) :: {:ok, Order.t()} | {:error, Ecto.Changeset.t()}
  def update_order(order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end
end

defmodule Profitry.Investment.Positions do
  @moduledoc """

    Operations on Position struct

  """

  import Ecto.Query

  alias Profitry.Investment
  alias Ecto.Changeset
  alias Profitry.Repo
  alias Profitry.Investment.Reports
  alias Profitry.Investment.Schema.{Portfolio, Position, Order, PositionReport}
  alias Profitry.Exchanges.Schema.Quote

  @doc """

  Creates a position on a portfolio

  ## Examples

      iex> create_position(portfolio, %{field: value})
      {:ok, %Position{}}

      iex> create_position(portfolio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_position(Portfolio.t(), map()) :: {:ok, Position.t()} | {:error, Changeset.t()}
  def create_position(portfolio, attrs) do
    %Position{}
    |> Position.changeset(attrs)
    |> Changeset.put_assoc(:portfolio, portfolio)
    |> Repo.insert()
  end

  @doc """

  Updates a position.

  ## Examples

      iex> update_position(position, %{field: new_value})
      {:ok, %Position{}}

      iex> update_position(position, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_position(Position.t(), map()) :: {:ok, Position.t()} | {:error, Changeset.t()}
  def update_position(%Position{} = position, attrs) do
    position
    |> Position.changeset(attrs)
    |> Repo.update()
  end

  @doc """

  Deletes a position.

  ## Examples

      iex> delete_position(position)
      {:ok, %Position{}}

      iex> delete_position(position)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_position(Position.t()) :: {:ok, Position.t()} | {:error, Changeset.t()}
  def delete_position(%Position{} = position) do
    position
    |> change_position()
    |> Repo.delete()
  end

  @doc """

  Returns an `%Ecto.Changeset{}` for tracking position changes.

  ## Examples

      iex> change_position(position)
      %Ecto.Changeset{data: %Position{}}

  """
  @spec change_position(Position.t(), map()) :: Changeset.t()
  def change_position(%Position{} = position, attrs \\ %{}) do
    Position.changeset(position, attrs)
  end

  @doc """

  Gets a single position.

  ## Examples

      iex> get_position!(123)
      %Position{}

      iex> get_position!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_position!(integer()) :: Position.t()
  def get_position!(id) do
    Repo.get!(Position, id)
  end

  @doc """
    Finds a portfolio position.

    ## Examples

        iex> find_position(portfolio, "tsla")
        %Position{}

        iex> find_position(portfolio, "xpto")
        nil

  """
  @spec find_position(Portfolio.t(), String.t()) :: Position.t() | nil
  def find_position(%Portfolio{} = portfolio, ticker) do
    portfolio = Repo.preload(portfolio, :positions)
    Enum.find(portfolio.positions, &(&1.ticker === ticker))
  end

  @doc """

  Makes a report on a position

  """
  @spec make_report(Position.t(), Quote.t() | nil) :: PositionReport.t()
  def make_report(position, quote \\ nil) do
    splits = Investment.find_splits(position.ticker)

    preload_orders(position)
    |> Reports.make_report(quote, splits)
  end

  @doc """

    Preloads the orders for a position

  """
  @spec preload_orders(Position.t()) :: Position.t()
  def preload_orders(position) do
    position = Repo.preload(position, orders: from(o in Order, order_by: [asc: o.inserted_at]))

    orders =
      for order <- position.orders do
        preload_option(order)
      end

    %Position{position | orders: orders}
  end

  @spec preload_option(Order.t()) :: Order.t()
  defp preload_option(%Order{instrument: :option} = order) do
    Repo.preload(order, :option)
  end

  @spec preload_option(Order.t()) :: Order.t()
  defp preload_option(order), do: order
end

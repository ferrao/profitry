defmodule Profitry.Investment.Portfolios do
  @moduledoc """

  Operations on Portfolio structs

  """

  alias Profitry.Investment
  alias Profitry.Investment.Schema.{PositionReport, Order}
  alias Ecto.Changeset
  alias Profitry.Repo
  alias Profitry.Investment.Schema.Portfolio

  @doc """

  Creates a portfolio.

  ## Examples

      iex> create_portfolio(%{field: value})
      {:ok, %Portfolio{}}

      iex> create_portfolio(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_portfolio(map()) :: {:ok, Portfolio.t()} | {:error, Changeset.t()}
  def create_portfolio(attrs) do
    %Portfolio{}
    |> Portfolio.changeset(attrs)
    |> Repo.insert()
  end

  @doc """

  Returns the list of portfolios.

  ## Examples

      iex> list_portfolios()
      [%Portfolio{}, ...]

  """
  @spec list_portfolios() :: list(Portfolio.t())
  def list_portfolios() do
    Repo.all(Portfolio)
  end

  @doc """

  Gets a single portfolio.

  ## Examples

      iex> get_portfolio!(123)
      %Portfolio{}

      iex> get_portfolio!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_portfolio!(integer()) :: Portfolio.t()
  def get_portfolio!(id) do
    Repo.get!(Portfolio, id)
  end

  @doc """

  Updates a portfolio.

  ## Examples

      iex> update_portfolio(portfolio, %{field: new_value})
      {:ok, %Portfolio{}}

      iex> update_portfolio(portfolio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_portfolio(Portfolio.t(), map()) :: {:ok, Portfolio.t()} | {:error, Changeset.t()}
  def update_portfolio(portfolio, attrs) do
    portfolio
    |> Portfolio.changeset(attrs)
    |> Repo.update()
  end

  @doc """

  Deletes a portfolio

  ## Examples

      iex> delete_portfolio(portfolio)
      {:ok, %Portfolio{}}

      iex> delete_portfolio(portfolio)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_portfolio(Portfolio.t()) :: {:ok, Portfolio.t()} | {:error, Changeset.t()}
  def delete_portfolio(portfolio) do
    portfolio
    |> change_portfolio()
    |> Repo.delete()
  end

  @doc """

  Returns an `%Ecto.Changeset{}` for tracking portfolio changes.

  ## Examples

      iex> change_portfolio(portfolio)
      %Ecto.Changeset{data: %Portfolio{}}

  """
  @spec change_portfolio(Portfolio.t(), map()) :: Changeset.t()
  def change_portfolio(%Portfolio{} = portfolio, attrs \\ %{}) do
    Portfolio.changeset(portfolio, attrs)
  end

  @doc """

  Lists reports for a portfolio

  Raises `Ecto.NoResultsError` if the Portfolio does not exist.

  ## Examples
    iex> list_reports!(123)
    %Report{}

    iex> list_reports!(666)
    %Report{}
    ** (Ecto.NoResultsError)

  """
  @spec list_reports!(integer()) :: list(PositionReport.t())
  def list_reports!(id) do
    portfolio =
      get_portfolio!(id)
      |> Repo.preload(:positions)

    for position <- portfolio.positions do
      position
      |> preload_position()
      |> Investment.make_report()
    end
    |> Enum.sort_by(& &1.profit, {:desc, Decimal})
  end

  @spec preload_position(PositionReport.t()) :: PositionReport.t()
  def preload_position(position) do
    position = Repo.preload(position, :orders)

    orders =
      for order <- position.orders do
        preload_order(order)
      end

    %{position | orders: orders}
  end

  @spec preload_order(Order.t()) :: Order.t()
  def preload_order(%Order{instrument: :option} = order) do
    Repo.preload(order, :option)
  end

  @spec preload_order(Order.t()) :: Order.t()
  def preload_order(order), do: order
end

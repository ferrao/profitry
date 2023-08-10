defmodule ProfitryApp.Investment do
  @moduledoc """
  The Profitry Investment context.
  """

  import Ecto.Query, warn: false
  alias ProfitryApp.Repo
  alias ProfitryApp.Accounts.User
  alias ProfitryApp.Investment.{Portfolio, Position, Report, Order}

  @doc """
  Returns the list of portfolios.

  ## Examples

      iex> list_portfolios()
      [%Portfolio{}, ...]


      iex> list_portfolios(user)
      [%Portfolio{}, ...]

  """
  def list_portfolios do
    Repo.all(Portfolio)
  end

  def list_portfolios(%User{} = user) do
    Ecto.assoc(user, :portfolios)
    |> Repo.all()
  end

  @doc """
  Gets a single portfolio.

  Raises `Ecto.NoResultsError` if the Portfolio does not exist.

  ## Examples

      iex> get_portfolio!(123)
      %Portfolio{}

      iex> get_portfolio!(456)
      ** (Ecto.NoResultsError)

      iex> get_portfolio!(user, 123)
      %Portfolio{}

      iex> get_portfolio!(user, 456)
      ** (Ecto.NoResultsError)

  """
  def get_portfolio!(id), do: Repo.get!(Portfolio, id)

  def get_portfolio!(%User{} = user, id) do
    Ecto.assoc(user, :portfolios)
    |> where([p], p.id == ^id)
    |> Repo.one()
  end

  @doc """
  Creates a portfolio.

  ## Examples

      iex> create_portfolio(user, %{field: value})
      {:ok, %Portfolio{}}

      iex> create_portfolio(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_portfolio(%User{} = user, attrs \\ %{}) do
    %Portfolio{}
    |> Portfolio.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a portfolio.

  ## Examples

      iex> update_portfolio(portfolio, %{field: new_value})
      {:ok, %Portfolio{}}

      iex> update_portfolio(portfolio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_portfolio(%Portfolio{} = portfolio, attrs) do
    portfolio
    |> Portfolio.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a portfolio.

  ## Examples

      iex> delete_portfolio(portfolio)
      {:ok, %Portfolio{}}

      iex> delete_portfolio(portfolio)
      {:error, %Ecto.Changeset{}}

  """
  def delete_portfolio(%Portfolio{} = portfolio) do
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
  def change_portfolio(%Portfolio{} = portfolio, attrs \\ %{}) do
    Portfolio.changeset(portfolio, attrs)
  end

  @doc """
  Lists reports for a portfolio  

  Raises `Ecto.NoResultsError` if the Portfolio does not exist.

  ## Examples
    iex> list_reports!(123)
    %PositionReport{}

    iex> list_reports!(666)
    %PositionReport{}
    ** (Ecto.NoResultsError)

  """
  def list_reports!(id) do
    portfolio =
      get_portfolio!(id)
      |> Repo.preload(:positions)

    for position <- portfolio.positions do
      quote = ProfitryApp.get_quote(position.ticker)

      position
      |> Repo.preload(:orders)
      |> Report.make_report(quote)
    end
    |> Enum.sort_by(& &1.profit, {:desc, Decimal})
  end

  @doc """
  Gets a single postion report

  Raises `Ecto.NoResultsError` if the Report does not exist.

  ## Examples

      iex> get_report(position)
      %Report{}

  """
  def get_report(position) do
    quote = ProfitryApp.get_quote(position.ticker)

    position
    |> Repo.preload(:orders)
    |> Report.make_report(quote)
  end

  @doc """
  Creates a position.

  ## Examples

      iex> create_position(portfolio, %{field: value})
      {:ok, %Position{}}

      iex> create_position(portfolio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_position(%Portfolio{} = portfolio, attrs \\ %{}) do
    %Position{}
    |> Position.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:portfolio, portfolio)
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
  def update_position(%Position{} = position, attrs) do
    position
    |> change_position(attrs)
    |> Repo.update()
  end

  @doc """
  Finds a portfolio position.

  ## Examples

      iex> find_position(portfolio, "tsla")
      %Position{}

      iex> find_position(portfolio, "xpto")
      nil

  """
  def find_position(%Portfolio{} = portfolio, ticker) do
    portfolio = portfolio |> Repo.preload(:positions)

    portfolio.positions
    |> Enum.find(&(&1.ticker == ticker))
  end

  @doc """
  Deletes a position.

  ## Examples

      iex> delete_position(%Position{})
      {:ok, %Portfolio{}}

      iex> delete_position(%Ecto.Changeset{})
      {:error, %Ecto.Changeset{}}

  """
  def delete_position(%Portfolio{} = portfolio, ticker) do
    portfolio.positions
    |> Enum.find(&(&1.ticker == ticker))
    |> change_position()
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking position changes.

  ## Examples

      iex> change_position(position)
      %Ecto.Changeset{data: %Position{}}

  """
  def change_position(%Position{} = position, attrs \\ %{}) do
    Position.changeset(position, attrs)
  end

  @doc """
  Returns the list of positions.

  ## Examples

      iex> list_orders(position)
      [%Order{}, ...]


  """
  def list_orders(%Position{} = position) do
    Ecto.assoc(position, :orders)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single order.

  Raises `Ecto.NoResultsError` if the Order does not exist.

  ## Examples

      iex> get_order!(123)
      %Order{}

      iex> get_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_order!(id), do: Repo.get!(Order, id)

  @doc """
  Creates an order.

  ## Examples

      iex> create_order(position, %{field: value})
      {:ok, %Order{}}

      iex> create_order(position, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_order(%Position{} = position, attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:position, position)
    |> Repo.insert()
  end

  @doc """
  Updates an order.

  ## Examples

      iex> update_order(order, %{field: new_value})
      {:ok, %Order{}}

      iex> update_order(order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an order.

  ## Examples

      iex> delete_order(order)
      {:ok, %Order{}}

      iex> delete_order(order)
      {:error, %Ecto.Changeset{}}

  """
  def delete_order(%Order{} = order) do
    order
    |> change_order()
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking order changes.

  ## Examples

      iex> change_order(order)
      %Ecto.Changeset{data: %Order{}}

  """
  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end
end

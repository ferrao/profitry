defmodule ProfitryApp.Core do
  @moduledoc """
  The Profitry Core context.
  """

  import Ecto.Query, warn: false
  alias ProfitryApp.Repo
  alias ProfitryApp.Accounts.User
  alias ProfitryApp.Core.{Portfolio, Position, Report}

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
  Lists reports for a portfolio  

  Raises `Ecto.NoResultsError` if the Portfolio does not exist.

  ## Examples
    iex> list_reports!(123)
    %Report{}

    iex> list_reports!(666)
    %Report{}
    ** (Ecto.NoResultsError)

  """
  def list_reports!(id) do
    portfolio =
      get_portfolio!(id)
      |> Repo.preload(:positions)

    for position <- portfolio.positions do
      position
      |> Repo.preload(:orders)
      |> Report.make_report()
    end
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
    Repo.delete(portfolio)
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
  Creates a position.

  ## Examples

      iex> create_position(user, %{field: value})
      {:ok, %Position{}}

      iex> create_position(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_position(%Portfolio{} = portfolio, attrs \\ %{}) do
    %Position{}
    |> Position.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:portfolio, portfolio)
    |> Repo.insert()
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
end

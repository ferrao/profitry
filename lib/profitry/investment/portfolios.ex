defmodule Profitry.Investment.Portfolios do
  @moduledoc """

  Operations on Portfolio structs

  """

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
  @spec create_portfolio(map()) :: {:ok, Portfolio.t()}
  def create_portfolio(attrs \\ %{}) do
    %Portfolio{}
    |> Portfolio.changeset(attrs)
    |> Repo.insert()
  end

  @doc """

  Returns the list of portfolios.

  ## Examples

      iex> list_portfolios()
      [%Portfolio{}, ...]


      iex> list_portfolios(user)
      [%Portfolio{}, ...]

  """
  @spec list_portfolios() :: list(Portfolio.t())
  def list_portfolios() do
    Repo.all(Portfolio)
  end

  @doc """

  Gets a single portfolio.

  Returns `nil` if the Portfolio does not exist.

  ## Examples

      iex> get_portfolio(123)
      %Portfolio{}

      iex> get_portfolio(456)
      nil

  """
  @spec get_portfolio(integer()) :: Portfolio.t() | nil
  def get_portfolio(id) do
    Repo.get(Portfolio, id)
  end

  @doc """

  Updates a portfolio.

  ## Examples

      iex> update_portfolio(portfolio, %{field: new_value})
      {:ok, %Portfolio{}}

      iex> update_portfolio(portfolio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_portfolio(Portfolio.t(), map()) :: {:ok, Portfolio.t()}
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
  @spec delete_portfolio(Portfolio.t()) :: {:ok, Portfolio.t()}
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
  @spec change_portfolio(Portfolio.t(), map()) :: Ecto.Changeset.t()
  def change_portfolio(%Portfolio{} = portfolio, attrs \\ %{}) do
    Portfolio.changeset(portfolio, attrs)
  end
end

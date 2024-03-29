defmodule Profitry.Investment do
  @moduledoc """

    The Investment Context

  """
  # import Ecto.Query
  alias Profitry.Repo
  alias Profitry.Investment.Portfolio

  @doc """
  Creates a portfolio.

  ## Examples

      iex> create_portfolio(%{field: value})
      {:ok, %Portfolio{}}

      iex> create_portfolio(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_portfolio(Map.t()) :: {:ok, Portfolio.t()} | {:error, Ecto.Changeset.t()}
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
  @spec get_portfolio(integer()) :: Portfolio.t()
  def get_portfolio(id) do
    Repo.get(Portfolio, id)
  end
end

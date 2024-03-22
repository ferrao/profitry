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
end

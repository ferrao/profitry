defmodule Profitry.Investment.Positions do
  alias Profitry.Repo
  alias Profitry.Investment.Schema.{Portfolio, Position}

  @doc """
  Creates a position on a portfolio

  ## Examples

      iex> create_position(portfolio, %{field: value})
      {:ok, %Position{}}

      iex> create_position(portfolio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_position(Portfolio.t(), Map.t()) ::
          {:ok, Position.t()} | {:error, Ecto.Changeset.t()}
  def create_position(portfolio, attrs \\ %{}) do
    %Position{}
    |> Position.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:portfolio, portfolio)
    |> Repo.insert()
  end
end

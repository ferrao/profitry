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

  @doc """
  Updates a position.

  ## Examples

      iex> update_position(position, %{field: new_value})
      {:ok, %Position{}}

      iex> update_position(position, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_position(Position.t(), Map.t()) ::
          {:ok, Position.t()} | {:error, Ecto.Changeset.t()}
  def update_position(%Position{} = position, attrs) do
    position
    |> Position.changeset(attrs)
    |> Repo.update()
  end
end

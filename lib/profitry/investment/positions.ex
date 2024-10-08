defmodule Profitry.Investment.Positions do
  @moduledoc """

    Operations on Position struct

  """

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
  @spec create_position(Portfolio.t(), map()) ::
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
  @spec update_position(Position.t(), map()) ::
          {:ok, Position.t()} | {:error, Ecto.Changeset.t()}
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
  @spec delete_position(Position.t()) :: {:ok, Position.t()} | {:error, Ecto.Changeset.t()}
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
  @spec change_position(Position.t(), map()) :: Ecto.Changeset.t()
  def change_position(%Position{} = position, attrs \\ %{}) do
    Position.changeset(position, attrs)
  end
end

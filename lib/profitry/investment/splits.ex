defmodule Profitry.Investment.Splits do
  @moduledoc """

  Operations on Splits struct

  """

  import Ecto.Query

  alias Ecto.Changeset
  alias Profitry.Repo
  alias Profitry.Investment.Schema.{Split, Position}

  @doc """

  Creates a stock split event

  ## Examples

      iex> create_split(%{field: value})
      {:ok, %Split{}}

      iex> create_Split(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_split(map()) :: {:ok, Split.t()} | {:error, Changeset.t()}
  def create_split(attrs \\ %{}) do
    %Split{}
    |> Split.changeset(attrs)
    |> Repo.insert()
  end

  @doc """

  Returns the list of stock splits

  ## Examples

      iex> list_splits()
      [%Split{}, ...]

  """
  @spec list_splits() :: list(Split.t())
  def list_splits() do
    Repo.all(Split)
  end

  @doc """

  Finds all stock splits for a position, accounting for ticker changes

  """
  @spec find_splits(Position.t()) :: list(Split.t())
  def find_splits(position) do
    historical_tickers = Profitry.Investment.fetch_historical_tickers(position.ticker)
    Repo.all(from s in Split, where: s.ticker in ^historical_tickers)
  end

  @doc """

  Gets a single stock split.

  ## Examples

      iex> get_split!(123)
      %Split{}

      iex> get_split!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_split!(integer()) :: Split.t()
  def get_split!(id) do
    Repo.get!(Split, id)
  end

  @doc """

  Updates a stock split event

  ## Examples

      iex> update_split(split, %{field: new_value})
      {:ok, %Split{}}

      iex> update_split(split, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_split(Split.t(), map()) :: {:ok, Split.t()} | {:error, Changeset.t()}
  def update_split(%Split{} = split, attrs) do
    split
    |> Split.changeset(attrs)
    |> Repo.update()
  end

  @doc """

  Deletes a stock split.

  ## Examples

      iex> delete_split(split)
      {:ok, %Split{}}

      iex> delete_split(split)
      {:error, %Ecto.Changeset{}}


  """
  @spec delete_split(Split.t()) :: {:ok, Split.t()} | {:error, Changeset.t()}
  def delete_split(%Split{} = split) do
    split
    |> change_split()
    |> Repo.delete()
  end

  @doc """

  Returns an `%Ecto.Changeset{}` for tracking stock split changes.

  ## Examples

      iex> change_split(split)
      %Ecto.Changeset{data: %Split{}}

  """
  @spec change_split(Split.t(), map()) :: Changeset.t()
  def change_split(%Split{} = split, attrs \\ %{}) do
    Split.changeset(split, attrs)
  end
end

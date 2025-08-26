defmodule Profitry.Investment.TickerChanges do
  @moduledoc """

  Operations on TickerChanges struct

  """

  alias Ecto.Changeset
  alias Profitry.Repo
  alias Profitry.Investment.Schema.TickerChange

  @doc """

  Creates a ticker change event

  ## Examples

      iex> create_ticker_change(%{field: value})
      {:ok, %TickerChange{}}

      iex> create_ticker_change(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_ticker_change(map()) :: {:ok, TickerChange.t()}
  def create_ticker_change(attrs \\ %{}) do
    %TickerChange{}
    |> TickerChange.changeset(attrs)
    |> Repo.insert()
  end

  @doc """

  Returns the list of ticker changes

  ## Examples

      iex> list_ticker_changes()
      [%TickerChange{}, ...]

  """
  @spec list_ticker_changes() :: list(TickerChange.t())
  def list_ticker_changes() do
    Repo.all(TickerChange)
  end

  @doc """

  Gets a single ticker change.

  ## Examples

    iex> get_ticker_change!(123)
    %TickerChange{}

    iex> get_ticker_change!(456)
    ** (Ecto.NoResultsError)

  """
  @spec get_ticker_change!(integer()) :: TickerChange.t()
  def get_ticker_change!(id) do
    Repo.get!(TickerChange, id)
  end

  @doc """

  Updates a ticker change event

  ## Examples

      iex> update_ticker_change(ticker_change, %{field: new_value})
      {:ok, %Tickerchange{}}

      iex> update_split(split, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_ticker_change(TickerChange.t(), map()) ::
          {:ok, TickerChange.t()} | {:error, Changeset.t()}
  def update_ticker_change(%TickerChange{} = ticker_change, attrs) do
    ticker_change
    |> TickerChange.changeset(attrs)
    |> Repo.update()
  end

  @doc """

  Deletes a ticker change.

  ## Examples

      iex> delete_ticker_change(ticker_change)
      {:ok, %TickerChange{}}

      iex> delete_ticker_change(ticker_change)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_ticker_change(TickerChange.t()) ::
          {:ok, TickerChange.t()} | {:error, Changeset.t()}
  def delete_ticker_change(%TickerChange{} = ticker_change) do
    ticker_change
    |> change_ticker_change()
    |> Repo.delete()
  end

  @doc """

  Returns an `%Ecto.Changeset{}` for tracking stock ticker changes.

  ## Examples

      iex> change_ticker_change(ticker_change)
      %Ecto.Changeset{data: %TickerChange{}}

  """
  @spec change_ticker_change(TickerChange.t(), map()) :: Changeset.t()
  def change_ticker_change(%TickerChange{} = ticker_change, attrs \\ %{}) do
    TickerChange.changeset(ticker_change, attrs)
  end
end

defmodule Profitry.Investment.Delistings do
  @moduledoc """

  Operations on Delistings struct

  """

  alias Ecto.Changeset
  alias Profitry.Repo
  alias Profitry.Investment.Schema.Delisting

  @doc """

  Creates a delisting event

  ## Examples

      iex> create_delisting(%{field: value})
      {:ok, %Delisting{}}

      iex> create_delisting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec create_delisting(map()) :: {:ok, Delisting.t()} | {:error, Changeset.t()}
  def create_delisting(attrs \\ %{}) do
    %Delisting{}
    |> Delisting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """

  Returns the list of delistings

  ## Examples

      iex> list_delistings()
      [%Delisting{}, ...]
  """
  @spec list_delistings() :: list(Delisting.t())
  def list_delistings() do
    Repo.all(Delisting)
  end

  @doc """

  Finds a delisting by ticker

  ## Examples

      iex> find_delisting_by_ticker("AAPL")
      %Delisting{}

      iex> find_delisting_by_ticker("INVALID")
      nil
  """
  @spec find_delisting_by_ticker(String.t()) :: Delisting.t() | nil
  def find_delisting_by_ticker(ticker) do
    Repo.get_by(Delisting, ticker: ticker)
  end

  @doc """

  Gets a single delisting.

  ## Examples

      iex> get_delisting!(123)
      %Delisting{}

      iex> get_delisting!(456)
      ** (Ecto.NoResultsError)
  """
  @spec get_delisting!(integer()) :: Delisting.t()
  def get_delisting!(id) do
    Repo.get!(Delisting, id)
  end

  @doc """

  Updates a delisting event

  ## Examples

      iex> update_delisting(delisting, %{field: new_value})
      {:ok, %Delisting{}}

      iex> update_delisting(delisting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  @spec update_delisting(Delisting.t(), map()) :: {:ok, Delisting.t()} | {:error, Changeset.t()}
  def update_delisting(%Delisting{} = delisting, attrs) do
    delisting
    |> Delisting.changeset(attrs)
    |> Repo.update()
  end

  @doc """

  Deletes a delisting.

  ## Examples

      iex> delete_delisting(delisting)
      {:ok, %Delisting{}}

      iex> delete_delisting(delisting)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete_delisting(Delisting.t()) :: {:ok, Delisting.t()} | {:error, Changeset.t()}
  def delete_delisting(%Delisting{} = delisting) do
    delisting
    |> change_delisting()
    |> Repo.delete()
  end

  @doc """

  Returns an `%Ecto.Changeset{}` for tracking delisting changes.

  ## Examples

      iex> change_delisting(delisting)
      %Ecto.Changeset{data: %Delisting{}}
  """
  @spec change_delisting(Delisting.t(), map()) :: Changeset.t()
  def change_delisting(%Delisting{} = delisting, attrs \\ %{}) do
    Delisting.changeset(delisting, attrs)
  end

  @doc """

  Checks if a ticker is delisted.

  ## Examples

      iex> ticker_delisted?("AAPL")
      true

      iex> ticker_delisted?("INVALID")
      false
  """
  @spec ticker_delisted?(String.t()) :: boolean()
  def ticker_delisted?(ticker) do
    not is_nil(find_delisting_by_ticker(ticker))
  end

  @doc """

  Checks if a position is delisted by finding its recent ticker.

  ## Examples

      iex> position_delisted?(position)
      true

      iex> position_delisted?(position)
      false
  """
  @spec position_delisted?(map()) :: boolean()
  def position_delisted?(position) do
    ticker_delisted?(position.ticker)
  end
end

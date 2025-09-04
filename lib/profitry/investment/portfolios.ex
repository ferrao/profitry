defmodule Profitry.Investment.Portfolios do
  @moduledoc """

  Operations on Portfolio structs

  """

  import Ecto.Query

  alias Profitry.Investment.Schema.Position
  alias Profitry.Investment
  alias Profitry.Investment.Schema.{PositionReport, Portfolio}
  alias Ecto.Changeset
  alias Profitry.Repo

  @doc """

  Creates a portfolio.

  ## Examples

      iex> create_portfolio(%{field: value})
      {:ok, %Portfolio{}}

      iex> create_portfolio(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_portfolio(map()) :: {:ok, Portfolio.t()} | {:error, Changeset.t()}
  def create_portfolio(attrs) do
    %Portfolio{}
    |> Portfolio.changeset(attrs)
    |> Repo.insert()
  end

  @doc """

  Returns the list of portfolios.

  ## Examples

      iex> list_portfolios()
      [%Portfolio{}, ...]

  """
  @spec list_portfolios() :: list(Portfolio.t())
  def list_portfolios() do
    Repo.all(Portfolio)
  end

  @doc """

  Gets a single portfolio.

  ## Examples

      iex> get_portfolio!(123)
      %Portfolio{}

      iex> get_portfolio!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_portfolio!(integer()) :: Portfolio.t()
  def get_portfolio!(id) do
    Repo.get!(Portfolio, id)
  end

  @doc """

  Updates a portfolio.

  ## Examples

      iex> update_portfolio(portfolio, %{field: new_value})
      {:ok, %Portfolio{}}

      iex> update_portfolio(portfolio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_portfolio(Portfolio.t(), map()) :: {:ok, Portfolio.t()} | {:error, Changeset.t()}
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
  @spec delete_portfolio(Portfolio.t()) :: {:ok, Portfolio.t()} | {:error, Changeset.t()}
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
  @spec change_portfolio(Portfolio.t(), map()) :: Changeset.t()
  def change_portfolio(%Portfolio{} = portfolio, attrs \\ %{}) do
    Portfolio.changeset(portfolio, attrs)
  end

  @doc """

  Lists reports for a portfolio, sorted by open positions and highest profit first
  and optionally filtered by ticker

  Raises `Ecto.NoResultsError` if the Portfolio does not exist.

  ## Examples
    iex> list_reports!(123)
    [%PositionReport{}]

    iex> list_reports!(123, "tsla")
    [%PositionReport{}]

    iex> list_reports!(666)
    ** (Ecto.NoResultsError)

  """
  @spec list_reports!(integer(), String.t() | nil) :: list(PositionReport.t())
  def list_reports!(id, filter_param) do
    portfolio =
      get_portfolio!(id)
      |> Repo.preload(positions: filter_query(filter_param))

    for position <- portfolio.positions do
      ticker = Investment.find_recent_ticker(position.ticker)
      quote = Profitry.get_quote(ticker)

      Investment.make_report(position, quote)
      |> Map.put(:ticker, ticker)
    end
    |> Enum.sort_by(& &1.profit, {:desc, Decimal})
    |> Enum.sort_by(&Investment.position_closed?(&1))
  end

  defp filter_query(filter_param) when filter_param in ["", nil] do
    from(p in Position)
  end

  defp filter_query(filter_param) do
    from(p in Position, where: ilike(p.ticker, ^"%#{filter_param}%"))
  end

  @doc """

  Lists all tickers across all portfolios

  ## Examples

    iex> list_tickers()
    ["TSLA", "AAPL", "GOOG", "UBER"]

  """
  @spec list_tickers() :: list(String.t())
  def list_tickers() do
    Position
    |> select([p], p.ticker)
    |> distinct(true)
    |> order_by([p], p.ticker)
    |> Repo.all()
    |> Enum.map(&Investment.find_recent_ticker/1)
    |> Enum.uniq()
    |> Enum.sort()
  end
end

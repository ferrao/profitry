defmodule Profitry.Exchanges.Clients.Finnhub.FinnhubQuote do
  @moduledoc """

  Schema representing a finnhub quote

  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Profitry.Exchanges.Schema.Quote
  alias Profitry.Utils.{UnixTime, Errors}

  @exchange "FINNHUB"

  @type t :: %__MODULE__{
          c: Decimal.t(),
          d: Decimal.t(),
          dp: Decimal.t(),
          h: Decimal.t(),
          l: Decimal.t(),
          o: Decimal.t(),
          pc: Decimal.t(),
          t: integer()
        }

  @primary_key false
  embedded_schema do
    field :c, :decimal
    field :d, :decimal
    field :dp, :decimal
    field :h, :decimal
    field :l, :decimal
    field :o, :decimal
    field :pc, :decimal
    field :t, UnixTime
  end

  @doc """

  Creates an Ecto Changeset for the Finnhub schema

  """
  @spec changeset(map()) :: Changeset.t()
  def changeset(data \\ %{}) do
    %__MODULE__{}
    |> cast(data, [:c, :d, :dp, :h, :l, :o, :pc, :t])
    |> validate_required([:c, :t])
    |> validate_number(:c, greater_than: 0)
  end

  @doc """

  Creates a new Quote from Finnhub data

  """
  @spec new(String.t(), map()) :: Quote.t() | {:error, String.t()}
  def new(ticker, data) do
    quote_from_data(ticker, changeset(data))
  end

  @spec quote_from_data(String.t(), Changeset.t()) :: Quote.t()
  defp quote_from_data(ticker, %Ecto.Changeset{valid?: true} = changeset) do
    data = Ecto.Changeset.apply_changes(changeset)

    %Quote{
      exchange: @exchange,
      ticker: ticker,
      price: data.c,
      timestamp: data.t
    }
  end

  @spec quote_from_data(String.t(), Changeset.t()) :: {:error, String.t()}
  defp quote_from_data(_ticker, changeset), do: {:error, Enum.at(Errors.get_errors(changeset), 0)}
end

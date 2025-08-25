defmodule Profitry.Investment.Schema.TickerChange do
  @moduledoc """

  Schema representing a ticker change

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  @type t :: %__MODULE__{
          ticker: String.t() | nil,
          original_ticker: String.t() | nil,
          date: Date.t() | nil
        }

  schema "ticker_changes" do
    field :ticker, :string
    field :original_ticker, :string
    field :date, :date

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(ticker_change, attrs) do
    ticker_change
    |> cast(attrs, [:ticker, :original_ticker, :date])
    |> validate_required([:ticker, :original_ticker, :date])
    |> capitalize([:ticker, :original_ticker])
    |> unique_constraint(:ticker_date, name: :ticker_date_ticker_changes_index)
    |> validate_not_equal(:ticker, :original_ticker)
  end
end

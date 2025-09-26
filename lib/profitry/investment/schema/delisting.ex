defmodule Profitry.Investment.Schema.Delisting do
  @moduledoc """
  Ecto schema representing a position delisting event
  """
  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  @type t :: %__MODULE__{
          date: Date.t() | nil,
          payout: Decimal.t() | nil,
          ticker: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "delistings" do
    field :date, :date
    field :payout, :decimal, default: Decimal.new("0.00")
    field :ticker, :string

    timestamps()
  end

  @doc """
  Creates an Ecto Changeset for the Delisting schema
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(delisting, attrs) do
    delisting
    |> cast(attrs, [:date, :payout, :ticker])
    |> validate_required([:date, :ticker])
    |> validate_number(:payout, greater_than_or_equal_to: 0)
    |> capitalize([:ticker])
    |> unique_constraint(:ticker, message: "Ticker already delisted")
  end
end

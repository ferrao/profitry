defmodule Profitry.Investment.Schema.Split do
  @moduledoc """

  Schema representing a position sotck split or reverse split

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  @type t :: %__MODULE__{
          ticker: String.t() | nil,
          multiple: Decimal.t() | nil,
          reverse: boolean() | nil,
          date: Date.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "splits" do
    field :ticker, :string
    field :multiple, :decimal
    field :reverse, :boolean
    field :date, :date

    timestamps()
  end

  @doc """

  Creates an Ecto Changeset for the Split schema

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(split, attrs) do
    split
    |> cast(attrs, [:ticker, :multiple, :reverse, :date])
    |> validate_required([:ticker, :multiple, :reverse, :date])
    |> validate_number(:multiple, greater_than: 0)
    |> capitalize(:ticker)
    |> unique_constraint(:ticker_date, name: :ticker_date_split_index)
  end
end

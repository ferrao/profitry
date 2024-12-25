defmodule Profitry.Investment.Schema.Split do
  @moduledoc """

  Schema representing a position sotck split or reverse split

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  @type t :: %__MODULE__{
          ticker: String.t(),
          multiple: integer(),
          reverse: boolean(),
          date: Date.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "splits" do
    field :ticker, :string
    field :multiple, :integer
    field :reverse, :boolean
    field :date, :date

    timestamps()
  end

  @doc """

  Creates an Ecto Changeset for the Split schema

  """
  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(split, attrs) do
    split
    |> cast(attrs, [:ticker, :multiple, :reverse, :date])
    |> validate_required([:ticker, :multiple, :reverse, :date])
    |> validate_number(:multiple, greater_than: 0)
    |> capitalize(:ticker)
    |> unique_constraint(:ticker_date, name: :ticker_date_split_index)
  end
end

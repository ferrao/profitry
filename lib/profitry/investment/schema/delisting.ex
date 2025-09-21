defmodule Profitry.Investment.Schema.Delisting do
  @moduledoc """
  Ecto schema representing a position delisting event
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Profitry.Investment.Schema.Position

  @type t :: %__MODULE__{
          delisted_on: Date.t() | nil,
          payout: Decimal.t() | nil,
          position: Position.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "delistings" do
    field :delisted_on, :date
    field :payout, :decimal, default: Decimal.new("0.00")
    belongs_to :position, Position

    timestamps()
  end

  @doc """
  Creates an Ecto Changeset for the Delisting schema
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(delisting, attrs) do
    delisting
    |> cast(attrs, [:delisted_on, :payout])
    |> validate_required([:delisted_on])
    |> validate_number(:payout, greater_than_or_equal_to: 0)
    |> assoc_constraint(:position)
    |> unique_constraint(:position_id, message: "Position already delisted")
  end
end

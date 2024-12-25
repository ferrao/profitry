defmodule Profitry.Investment.Schema.Order do
  @moduledoc """

  Ecto schema representing a buy or a sell order on stocks or premium

  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Profitry.Investment.Schema.{Option, Position}

  @type order :: :buy | :sell
  @type instrument :: :stock | :option
  @type t :: %__MODULE__{
          type: order | nil,
          instrument: instrument | nil,
          quantity: Decimal.t() | nil,
          price: Decimal.t() | nil,
          option: Option.t() | Ecto.Association.NotLoaded.t() | nil,
          position: Position.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "orders" do
    field :type, Ecto.Enum, values: [:buy, :sell]
    field :instrument, Ecto.Enum, values: [:stock, :option]
    field :quantity, :decimal
    field :price, :decimal
    has_one :option, Option
    belongs_to :position, Position

    timestamps()
  end

  @doc """

  Creates an Ecto Changeset for the order schema

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:type, :instrument, :quantity, :price, :inserted_at])
    |> cast_assoc(:option)
    |> validate_required([:type, :instrument, :quantity, :price, :inserted_at])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end
end

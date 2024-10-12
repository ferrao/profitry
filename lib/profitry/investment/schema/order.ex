defmodule Profitry.Investment.Schema.Order do
  @moduledoc """

  Ecto schema representing a buy or a sell order on stocks or premium

  """

  use Ecto.Schema

  import Ecto.Changeset
  alias Ecto.Changeset
  alias Profitry.Investment.Schema.{Option, Position}

  @type order :: :buy | :sell
  @type instrument :: :stock | :option
  @type t :: %__MODULE__{
          type: order,
          instrument: instrument,
          quantity: Decimal.t(),
          price: Decimal.t(),
          option: nil | Option.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
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

  @spec changeset(t(), map()) :: Changeset.t()
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:type, :instrument, :quantity, :price, :inserted_at])
    |> cast_assoc(:option)
    |> validate_required([:type, :instrument, :quantity, :price, :inserted_at])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end
end

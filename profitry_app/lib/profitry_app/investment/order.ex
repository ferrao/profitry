defmodule ProfitryApp.Investment.Order do
  @moduledoc """

  Schema representing a buy or sell order on stocks or premium

  """
  use Ecto.Schema

  import Ecto.Changeset
  alias ProfitryApp.Investment.{Position, Option}

  @type order :: :buy | :sell
  @type instrument :: :stock | :option
  @type t :: %__MODULE__{
          type: order,
          instrument: instrument,
          quantity: Decimal.t(),
          price: Decimal.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "orders" do
    field(:type, Ecto.Enum, values: [:buy, :sell])
    field(:instrument, Ecto.Enum, values: [:stock, :option])
    field(:quantity, :decimal)
    field(:price, :decimal)
    belongs_to(:position, Position)
    has_one(:option, Option)

    timestamps()
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [:type, :instrument, :quantity, :price, :inserted_at])
    |> validate_required([:type, :instrument, :quantity, :price, :inserted_at])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end
end

defmodule ProfitryApp.Investment.Order do
  use Ecto.Schema

  import Ecto.Changeset
  alias ProfitryApp.Investment.{Position, Option}

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

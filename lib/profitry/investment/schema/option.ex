defmodule Profitry.Investment.Schema.Option do
  @moduledoc """

  Schema representing the details of an options contract for an order to buy/sell premium

  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Profitry.Investment.Schema.Order

  @type t :: %__MODULE__{
          strike: Integer.t(),
          expiration: Date.t(),
          order: Order.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "options" do
    field :strike, :integer
    field :expiration, :date
    belongs_to :order, Order

    timestamps()
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, [:strike, :expiration])
    |> validate_required([:strike, :expiration])
    |> validate_number(:strike, greater_than: 0)
  end
end

defmodule ProfitryApp.Investment.Option do
  use Ecto.Schema

  import Ecto.Changeset
  alias ProfitryApp.Investment.Order

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

defmodule Profitry.Investment.Schema.Portfolio do
  @moduledoc """

  Ecto Schema representing a portfolio of positions  

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  alias Profitry.Investment.Schema.Position

  @type t :: %__MODULE__{
          broker: String.t(),
          description: String.t(),
          positions: list(Position.t()),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "portfolios" do
    field :broker, :string
    field :description, :string
    has_many :positions, Position

    timestamps()
  end

  def changeset(portfolio, attrs) do
    portfolio
    |> cast(attrs, [:broker, :description])
    |> validate_required([:broker, :description])
    |> capitalize(:broker)
    |> no_assoc_constraint(:positions, message: "Portfolio contains positions")
  end
end

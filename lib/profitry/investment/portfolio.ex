defmodule Profitry.Investment.Portfolio do
  @moduledoc """

  Schema representing a portfolio of positions  

  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Profitry.Investment.Position

  @type t :: %__MODULE__{
          broker: String.t(),
          description: String.t(),
          positions: list(Position.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
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
    |> no_assoc_constraint(:positions, message: "Portfolio contains positions")
  end
end

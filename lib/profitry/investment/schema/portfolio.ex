defmodule Profitry.Investment.Schema.Portfolio do
  @moduledoc """

  Ecto Schema representing a portfolio of positions

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  alias Profitry.Investment.Schema.Position

  @type t :: %__MODULE__{
          broker: String.t() | nil,
          description: String.t() | nil,
          positions: list(Position.t()) | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "portfolios" do
    field :broker, :string
    field :description, :string
    has_many :positions, Position

    timestamps()
  end

  @doc """

  Creates an Ecto Changeset for the Portfolio schema

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(portfolio, attrs) do
    portfolio
    |> cast(attrs, [:broker, :description])
    |> validate_required([:broker, :description])
    |> capitalize(:broker)
    |> no_assoc_constraint(:positions, message: "Portfolio contains positions")
    |> unique_constraint(:broker)
  end
end

defmodule ProfitryApp.Investment.Portfolio do
  @moduledoc """

  Schema representing a portfolio of positions 

  """
  use Ecto.Schema

  import Ecto.Changeset
  import ProfitryApp.Utils.Ecto

  alias ProfitryApp.Accounts.User
  alias ProfitryApp.Investment.Position

  @type t :: %__MODULE__{
          name: String.t(),
          ticker: String.t(),
          positions: list(Position.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "portfolios" do
    field :name, :string
    field :ticker, :string
    has_many :positions, Position
    belongs_to :user, User

    timestamps()
  end

  def changeset(portfolio, attrs) do
    portfolio
    |> cast(attrs, [:ticker, :name])
    |> validate_required([:ticker, :name])
    |> capitalize(:ticker)
    |> no_assoc_constraint(:positions, message: "Portfolio contains positions")
  end
end

defmodule ProfitryApp.Investment.Portfolio do
  use Ecto.Schema

  import Ecto.Changeset
  import ProfitryApp.Utils.Ecto

  alias ProfitryApp.Accounts.User
  alias ProfitryApp.Investment.Position

  schema "portfolios" do
    field :name, :string
    field :tikr, :string
    has_many :positions, Position
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(portfolio, attrs) do
    portfolio
    |> cast(attrs, [:tikr, :name])
    |> validate_required([:tikr, :name])
    |> capitalize(:tikr)
    |> no_assoc_constraint(:positions, message: "Portfolio contains positions")
  end
end

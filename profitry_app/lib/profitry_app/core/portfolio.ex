defmodule ProfitryApp.Core.Portfolio do
  use Ecto.Schema

  import Ecto.Changeset
  alias ProfitryApp.Accounts.User

  schema "portfolios" do
    field :name, :string
    field :tikr, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(portfolio, attrs) do
    portfolio
    |> cast(attrs, [:tikr, :name])
    |> validate_required([:tikr, :name])
  end
end

defmodule Profitry.Investment.Schema.Split do
  @moduledoc """

  Schema representing a position sotck split or reverse split

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  @type t :: %__MODULE__{
          ticker: String.t(),
          multiplier: integer(),
          reverse: boolean(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "splits" do
    field :ticker, :string
    field :multiplier, :integer
    field :reverse, :boolean

    timestamps()
  end

  def changeset(split, attrs) do
    split
    |> cast(attrs, [:ticker, :multiplier, :reverse, :inserted_at])
    |> validate_required([:ticker, :multiplier, :reverse, :inserted_at])
    |> validate_number(:multiplier, greater_than: 0)
    |> capitalize(:ticker)
    |> unique_constraint(:ticker)
  end
end

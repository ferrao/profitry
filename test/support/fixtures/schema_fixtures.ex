defmodule Profitry.SchemaFixtures.Test do
  use Ecto.Schema

  schema "test" do
    field :first, :string
    field :second, :string
  end
end

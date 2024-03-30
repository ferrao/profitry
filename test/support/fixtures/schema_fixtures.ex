defmodule Profitry.SchemaFixtures.Test do
  @moduledoc """
  This module defines a test schema  
  """
  use Ecto.Schema

  schema "test" do
    field :first, :string
    field :second, :string
  end
end

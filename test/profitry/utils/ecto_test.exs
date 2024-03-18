defmodule Profitry.Utils.EctoTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset
  import Profitry.Utils.Ecto

  alias Profitry.SchemaFixtures.Test

  describe "ecto utils" do
    test "capitalize single" do
      changeset = cast(%Test{}, %{first: "x", second: "xs"}, [:first, :second])

      changeset = capitalize(changeset, [:second])

      assert "x" = changeset.changes.first
      assert "XS" = changeset.changes.second
    end

    test "capitalize multiple" do
      changeset = cast(%Test{}, %{first: "x", second: "xs"}, [:first, :second])

      changeset = capitalize(changeset, [:first, :second])

      assert "X" = changeset.changes.first
      assert "XS" = changeset.changes.second
    end
  end
end

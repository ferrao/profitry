defmodule Profitry.Investment.Schema.PositionTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.Position

  describe "position" do
    test "ticker is required" do
      changeset = Position.changeset(%Position{}, %{})

      assert ["can't be blank"] = errors_on(changeset).ticker
    end

    test "ticker is capitalized" do
      changeset = Position.changeset(%Position{}, %{ticker: "aapl"})

      assert "AAPL" = changeset.changes.ticker
    end
  end
end

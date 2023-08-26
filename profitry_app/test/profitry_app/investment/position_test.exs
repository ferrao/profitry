defmodule ProfitryApp.Investment.PositionTest do
  use ProfitryApp.DataCase, async: true

  alias ProfitryApp.Investment.Position

  describe "position" do
    test "ticker is required" do
      changeset = Position.changeset(%Position{}, %{})
      assert ["can't be blank"] = errors_on(changeset).ticker
    end

    test "ticker is capitalized" do
      changeset1 = Position.changeset(%Position{}, %{ticker: "aApl"})
      changeset2 = Position.changeset(%Position{}, %{ticker: "AAPL"})
      assert %{changes: %{ticker: "AAPL"}} = changeset1
      assert %{changes: %{ticker: "AAPL"}} = changeset2
    end
  end
end

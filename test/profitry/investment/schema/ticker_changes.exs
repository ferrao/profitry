defmodule Profitry.Investment.Schema.TickerChangesTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.TickerChanges

  describe "TickerChanges" do
    test "changes are created correctly" do
      changes =
        TickerChanges.changeset(%TickerChanges{}, %{
          ticker: "AAPL",
          original_ticker: "AAAA",
          date: ~D[2022-01-01]
        })

      assert changes.valid?
    end

    test "ticker is required" do
      changeset = TickerChanges.changeset(%TickerChanges{}, %{})
      assert ["can't be blank"] = errors_on(changeset).ticker
    end

    test "original ticker is required" do
      changeset = TickerChanges.changeset(%TickerChanges{}, %{})
      assert ["can't be blank"] = errors_on(changeset).original_ticker
    end

    test "date is required" do
      changeset = TickerChanges.changeset(%TickerChanges{}, %{})
      assert ["can't be blank"] = errors_on(changeset).date
    end
  end
end

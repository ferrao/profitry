defmodule Profitry.Investment.Schema.TickerChangeTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.TickerChange

  describe "TickerChange" do
    test "changes are created correctly" do
      changes =
        TickerChange.changeset(%TickerChange{}, %{
          ticker: "AAPL",
          original_ticker: "AAAA",
          date: ~D[2022-01-01]
        })

      assert changes.valid?
    end

    test "ticker is required" do
      changeset = TickerChange.changeset(%TickerChange{}, %{})
      assert ["can't be blank"] = errors_on(changeset).ticker
    end

    test "original ticker is required" do
      changeset = TickerChange.changeset(%TickerChange{}, %{ticker: "aapl"})
      assert ["can't be blank"] = errors_on(changeset).original_ticker
    end

    test "date is required" do
      changeset = TickerChange.changeset(%TickerChange{}, %{})
      assert ["can't be blank"] = errors_on(changeset).date
    end

    test "ticker can not be equal to original_ticker" do
      changeset =
        TickerChange.changeset(%TickerChange{}, %{ticker: "appl", original_ticker: "APPL"})

      assert ["original_ticker cannot be the same as ticker"] =
               errors_on(changeset).original_ticker
    end
  end
end

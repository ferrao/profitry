defmodule Profitry.Investment.Schema.DelistingTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.Delisting

  describe "delisting" do
    test "changes are created correctly" do
      changes =
        Delisting.changeset(%Delisting{}, %{
          date: ~D[2024-01-15],
          payout: Decimal.new("0.10"),
          ticker: "AAPL"
        })

      assert changes.valid?
    end

    test "date is required" do
      changeset = Delisting.changeset(%Delisting{}, %{})
      assert ["can't be blank"] = errors_on(changeset).date
    end

    test "ticker is required" do
      changeset = Delisting.changeset(%Delisting{}, %{})
      assert ["can't be blank"] = errors_on(changeset).ticker
    end

    test "payout defaults to zero" do
      changeset = Delisting.changeset(%Delisting{}, %{date: ~D[2024-01-15], ticker: "AAPL"})

      assert Decimal.compare(changeset.data.payout, Decimal.new("0")) === :eq
    end

    test "payout has to be greater than or equal to zero" do
      changeset1 =
        Delisting.changeset(%Delisting{}, %{
          date: ~D[2024-01-15],
          payout: "-1",
          ticker: "AAPL"
        })

      changeset2 =
        Delisting.changeset(%Delisting{}, %{
          date: ~D[2024-01-15],
          payout: "0",
          ticker: "AAPL"
        })

      assert ["must be greater than or equal to 0"] = errors_on(changeset1).payout
      assert Map.has_key?(errors_on(changeset2), :payout) === false
    end

    test "ticker is capitalized" do
      changeset =
        Delisting.changeset(%Delisting{}, %{
          date: ~D[2024-01-15],
          payout: Decimal.new("0.10"),
          ticker: "aapl"
        })

      assert changeset.changes.ticker == "AAPL"
    end
  end
end

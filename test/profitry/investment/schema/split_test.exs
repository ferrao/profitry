defmodule Profitry.Investment.Schema.SplitsTests do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.Split

  describe "split" do
    test "changes are created correctly" do
      changes =
        Split.changeset(%Split{}, %{
          ticker: "AAPL",
          multiple: 3,
          reverse: false,
          date: ~D[2025-08-22]
        })

      assert changes.valid?
    end

    test "ticker is required" do
      changeset = Split.changeset(%Split{}, %{})
      assert ["can't be blank"] = errors_on(changeset).ticker
    end

    test "multiple is required" do
      changeset = Split.changeset(%Split{}, %{})
      assert ["can't be blank"] = errors_on(changeset).multiple
    end

    test "reverse is required" do
      changeset = Split.changeset(%Split{}, %{})
      assert ["can't be blank"] = errors_on(changeset).reverse
    end

    test "date is required" do
      changeset = Split.changeset(%Split{}, %{})
      assert ["can't be blank"] = errors_on(changeset).date
    end

    test "multiple has to be greater than zero" do
      error = "must be greater than 0"

      changeset1 = Split.changeset(%Split{}, %{multiple: "0"})
      changeset2 = Split.changeset(%Split{}, %{multiple: "-1"})

      assert [^error] = errors_on(changeset1).multiple
      assert [^error] = errors_on(changeset2).multiple
    end
  end
end

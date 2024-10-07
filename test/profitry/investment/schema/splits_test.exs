defmodule Profitry.Investment.Schema.SplitsTests do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.{Split, Option}

  describe "split" do
    test "ticker is required" do
      changeset = Split.changeset(%Split{}, %{})
      assert ["can't be blank"] = errors_on(changeset).ticker
    end

    test "multiplier is required" do
      changeset = Split.changeset(%Split{}, %{})
      assert ["can't be blank"] = errors_on(changeset).multiplier
    end

    test "reverse is required" do
      changeset = Split.changeset(%Split{}, %{})
      assert ["can't be blank"] = errors_on(changeset).reverse
    end

    test "inserted_at is required" do
      changeset = Split.changeset(%Split{}, %{})
      assert ["can't be blank"] = errors_on(changeset).inserted_at
    end

    test "multiplier has to be greater than zero" do
      error = "must be greater than 0"

      changeset1 = Option.changeset(%Split{}, %{multiplier: "0"})
      changeset2 = Option.changeset(%Split{}, %{multiplier: "-1"})

      assert [^error] = errors_on(changeset1).multiplier
      assert [^error] = errors_on(changeset2).multiplier
    end
  end
end

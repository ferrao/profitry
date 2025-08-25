defmodule Profitry.Investment.Schema.OptionTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.Option

  describe "option" do
    test "changes are created correctly" do
      changes =
        Option.changeset(%Option{}, %{
          type: :call,
          strike: 130,
          expiration: ~D[2000-01-01]
        })

      assert changes.valid?
    end

    test "number of shares per contracts is 100" do
      assert Option.shares_per_contract() === 100
    end

    test "calculates option value " do
      assert Decimal.compare(Option.option_value(Decimal.new("1.27")), "127.00") === :eq
    end

    test "type is required" do
      changeset = Option.changeset(%Option{}, %{})
      assert ["can't be blank"] = errors_on(changeset).type
    end

    test "strike is required" do
      changeset = Option.changeset(%Option{}, %{})
      assert ["can't be blank"] = errors_on(changeset).strike
    end

    test "expiration is required" do
      changeset = Option.changeset(%Option{}, %{})
      assert ["can't be blank"] = errors_on(changeset).expiration
    end

    test "strike has to be greater than zero" do
      error = "must be greater than 0"

      changeset1 = Option.changeset(%Option{}, %{strike: "0"})
      changeset2 = Option.changeset(%Option{}, %{strike: "-1"})

      assert [^error] = errors_on(changeset1).strike
      assert [^error] = errors_on(changeset2).strike
    end

    test "expired?/1 returns true if option has expired" do
      assert false === Option.expired?(%Option{expiration: Date.add(Date.utc_today(), 1)})
      assert false === Option.expired?(%Option{expiration: Date.utc_today()})
      assert true === Option.expired?(%Option{expiration: Date.add(Date.utc_today(), -1)})
    end
  end
end

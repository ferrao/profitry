defmodule Profitry.Investment.OptionTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Option

  describe "option" do
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
  end
end

defmodule Profitry.Investment.Schema.PortfolioTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.Portfolio

  describe "portfolio" do
    test "changes are created correctly" do
      changes = Portfolio.changeset(%Portfolio{}, %{broker: "ETOR", description: "eToro"})

      assert changes.valid?
    end

    test "broker is required" do
      changeset = Portfolio.changeset(%Portfolio{}, %{})

      assert ["can't be blank"] = errors_on(changeset).broker
    end

    test "description is required" do
      changeset = Portfolio.changeset(%Portfolio{}, %{})

      assert ["can't be blank"] = errors_on(changeset).description
    end
  end
end

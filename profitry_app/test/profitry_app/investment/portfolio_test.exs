defmodule ProfitryApp.Investment.PortfolioTest do
  use ProfitryApp.DataCase, async: true

  alias ProfitryApp.Investment.Portfolio

  describe "portfolio" do
    test "ticker is required" do
      changeset = Portfolio.changeset(%Portfolio{}, %{})
      assert ["can't be blank"] = errors_on(changeset).ticker
    end

    test "name is required" do
      changeset = Portfolio.changeset(%Portfolio{}, %{})
      assert ["can't be blank"] = errors_on(changeset).name
    end

    test "ticker is capitalized" do
      changeset1 = Portfolio.changeset(%Portfolio{}, %{ticker: "iBkr"})
      changeset2 = Portfolio.changeset(%Portfolio{}, %{ticker: "IBKR"})
      assert %{changes: %{ticker: "IBKR"}} = changeset1
      assert %{changes: %{ticker: "IBKR"}} = changeset2
    end
  end
end

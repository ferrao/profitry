defmodule Profitry.Investment.PortfolioTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Portfolio

  describe "portfolio" do
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

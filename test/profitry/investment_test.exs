defmodule Profitry.InvestmentTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment
  alias Profitry.Investment.Portfolio

  describe "investment" do
    test "create_portfolio/1 with valid data creates portfol" do
      attrs = %{broker: "eToro", description: "Lame portfolio"}

      assert {:ok, %Portfolio{} = portfolio} = Investment.create_portfolio(attrs)
      assert portfolio.broker == attrs.broker
      assert portfolio.description == attrs.description
    end

    test "create_portfolio/1 with invalid data creates an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(%{})
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(%{broker: "eToro"})
      assert {:error, %Ecto.Changeset{}} = Investment.create_portfolio(%{description: "You wish"})
    end
  end
end

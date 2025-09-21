defmodule Profitry.Investment.Schema.DelistingTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment.Schema.Delisting

  describe "delisting" do
    test "changes are created correctly" do
      {_portfolio, position} = position_fixture()

      changes =
        Delisting.changeset(%Delisting{}, %{
          delisted_on: ~D[2024-01-15],
          payout: Decimal.new("0.10"),
          position_id: position.id
        })

      assert changes.valid?
    end

    test "delisted_on is required" do
      changeset = Delisting.changeset(%Delisting{}, %{})
      assert ["can't be blank"] = errors_on(changeset).delisted_on
    end

    test "payout defaults to zero" do
      changeset = Delisting.changeset(%Delisting{}, %{delisted_on: ~D[2024-01-15]})

      assert Decimal.compare(changeset.data.payout, Decimal.new("0")) === :eq
    end

    test "payout has to be greater than or equal to zero" do
      {_portfolio, position} = position_fixture()

      changeset1 =
        Delisting.changeset(%Delisting{}, %{
          delisted_on: ~D[2024-01-15],
          payout: "-1",
          position_id: position.id
        })

      changeset2 =
        Delisting.changeset(%Delisting{}, %{
          delisted_on: ~D[2024-01-15],
          payout: "0",
          position_id: position.id
        })

      assert ["must be greater than or equal to 0"] = errors_on(changeset1).payout
      assert Map.has_key?(errors_on(changeset2), :payout) === false
    end
  end
end

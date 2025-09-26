defmodule Profitry.Investment.DelistingsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Schema.Delisting

  describe "delisting" do
    test "create_delisting/1 with valid data creates a delisting" do
      attrs = %{
        date: "2024-01-15",
        payout: "0.10",
        ticker: "AAPL"
      }

      assert {:ok, %Delisting{} = delisting} = Investment.create_delisting(attrs)
      assert delisting.date === Date.from_iso8601!("2024-01-15")
      assert Decimal.eq?(delisting.payout, Decimal.new("0.10")) === true
      assert delisting.ticker === "AAPL"
    end

    test "create_delisting/1 with invalid data creates an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_delisting(%{})
    end

    test "list_delistings/0 returns existing delistings" do
      delisting = delisting_fixture()

      assert [delisting] === Investment.list_delistings()
    end

    test "get_delisting!/1 returns existing delisting" do
      delisting = delisting_fixture()

      assert delisting === Investment.get_delisting!(delisting.id)
    end

    test "get_delisting!/1 with invalid id raises error" do
      assert_raise Ecto.NoResultsError, fn -> Investment.get_delisting!(9999) end
    end

    test "find_delisting_by_ticker/1 returns delisting for ticker" do
      delisting = delisting_fixture("AAPL")

      assert delisting === Investment.find_delisting_by_ticker("AAPL")
    end

    test "find_delisting_by_ticker/1 returns nil for non-existent ticker" do
      assert Investment.find_delisting_by_ticker("INVALID") === nil
    end

    test "update_delisting/2 with valid data updates a delisting" do
      delisting = delisting_fixture()
      attrs = %{date: ~D[2024-02-15], payout: "0.15"}

      assert {:ok, %Delisting{} = updated_delisting} =
               Investment.update_delisting(delisting, attrs)

      assert updated_delisting.date === Date.from_iso8601!("2024-02-15")
      assert Decimal.eq?(updated_delisting.payout, Decimal.new("0.15")) === true
    end

    test "update_delisting/2 with invalid data does not update a delisting" do
      delisting = delisting_fixture()
      attrs = %{payout: "-1"}

      assert {:error, %Ecto.Changeset{}} = Investment.update_delisting(delisting, attrs)
    end

    test "change_delisting/1 returns a delisting changeset" do
      delisting = delisting_fixture()

      assert %Ecto.Changeset{} = Investment.change_delisting(delisting)
    end

    test "delete_delisting/1 deletes delisting" do
      delisting = delisting_fixture()

      assert {:ok, %Delisting{}} = Investment.delete_delisting(delisting)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Delisting, delisting.id) end
    end

    test "ticker_delisted?/1 returns true for delisted ticker" do
      delisting_fixture("AAPL")

      assert Investment.ticker_delisted?("AAPL") === true
    end

    test "ticker_delisted?/1 returns false for non-delisted ticker" do
      assert Investment.ticker_delisted?("INVALID") === false
    end

    test "position_delisted?/1 returns true for delisted position" do
      delisting_fixture("AAPL")
      {_portfolio, position} = position_fixture()
      position = %{position | ticker: "AAPL"}

      assert Investment.position_delisted?(position) === true
    end

    test "position_delisted?/1 returns false for non-delisted position" do
      {_portfolio, position} = position_fixture()

      assert Investment.position_delisted?(position) === false
    end
  end
end

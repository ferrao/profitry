defmodule Profitry.Investment.DelistingsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Schema.Delisting

  describe "delisting" do
    test "create_delisting/1 with valid data creates a delisting" do
      attrs = %{
        delisted_on: "2024-01-15",
        payout: "0.10"
      }

      assert {:ok, %Delisting{} = delisting} = Investment.create_delisting(attrs)
      assert delisting.delisted_on === Date.from_iso8601!("2024-01-15")
      assert Decimal.eq?(delisting.payout, Decimal.new("0.10")) === true
    end

    test "create_delisting/1 with invalid data creates an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_delisting(%{})
    end

    test "list_delistings/0 returns existing delistings" do
      {_portfolio, _position, delisting} = delisting_fixture()

      assert [delisting] ===
               Investment.list_delistings()
               |> Repo.preload(:position)
               |> Repo.preload(position: :portfolio)
    end

    test "get_delisting!/1 returns existing delisting" do
      {_portfolio, _position, delisting} = delisting_fixture()

      assert delisting ===
               Investment.get_delisting!(delisting.id)
               |> Repo.preload(:position)
               |> Repo.preload(position: :portfolio)
    end

    test "get_delisting!/1 with invalid id raises error" do
      assert_raise Ecto.NoResultsError, fn -> Investment.get_delisting!(9999) end
    end

    test "find_delisting/1 returns delisting for position" do
      {_portfolio, position, delisting} = delisting_fixture()

      assert delisting ===
               Investment.find_delisting(position.id)
               |> Repo.preload(:position)
               |> Repo.preload(position: :portfolio)
    end

    test "find_delisting/1 returns nil for non-existent position" do
      assert Investment.find_delisting(9999) === nil
    end

    test "update_delisting/2 with valid data updates a delisting" do
      {_portfolio, _position, delisting} = delisting_fixture()
      attrs = %{delisted_on: ~D[2024-02-15], payout: "0.15"}

      assert {:ok, %Delisting{} = updated_delisting} =
               Investment.update_delisting(delisting, attrs)

      assert updated_delisting.delisted_on === Date.from_iso8601!("2024-02-15")
      assert Decimal.eq?(updated_delisting.payout, Decimal.new("0.15")) === true
    end

    test "update_delisting/2 with invalid data does not update a delisting" do
      {_portfolio, _position, delisting} = delisting_fixture()
      attrs = %{payout: "-1"}

      assert {:error, %Ecto.Changeset{}} = Investment.update_delisting(delisting, attrs)
    end

    test "change_delisting/1 returns a delisting changeset" do
      {_portfolio, _posistion, delisting} = delisting_fixture()

      assert %Ecto.Changeset{} = Investment.change_delisting(delisting)
    end

    test "delete_delisting/1 deletes delisting" do
      {_portfolio, _position, delisting} = delisting_fixture()

      assert {:ok, %Delisting{}} = Investment.delete_delisting(delisting)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Delisting, delisting.id) end
    end

    test "position_delisted?/1 returns true for delisted position" do
      {_portfolio, position, _delisting} = delisting_fixture()

      assert Investment.position_delisted?(position.id) === true
    end

    test "position_delisted?/1 returns false for non-delisted position" do
      {_portfolio, position} = position_fixture()

      assert Investment.position_delisted?(position.id) === false
    end
  end
end

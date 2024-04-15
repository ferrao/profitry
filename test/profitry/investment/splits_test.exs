defmodule Profitry.Investment.SplitsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Splits
  alias Profitry.Investment.Schema.Split

  describe "split" do
    test "create_split/1 with valid data creates a stock split" do
      attrs = %{
        ticker: "aapl",
        multiplier: "2",
        reverse: false,
        inserted_at: "2024-01-01 12:00:07"
      }

      assert {:ok, %Split{} = split} = Investment.create_split(attrs)
      assert split.ticker == String.upcase(attrs.ticker)
      assert split.multiplier == String.to_integer(attrs.multiplier)
      assert split.reverse == attrs.reverse
      assert split.inserted_at == NaiveDateTime.from_iso8601!(attrs.inserted_at)
      assert split == Repo.get!(Split, split.id)
    end

    test "create_split/1 with invalid data creates an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_split(%{})
    end

    test "list_splits/0 returns existing stock splits" do
      split = split_fixture()

      assert Investment.list_splits() == [split]
    end

    test "find_splits/1 resturns stock splits for a ticker" do
      split = split_fixture()

      assert Investment.find_splits(split.ticker) == [split]
    end

    test "find_splits/1 resturns an empty list for a stock with no splits" do
      split_fixture()

      assert Investment.find_splits("invalid") == []
    end

    test "update_splt/2 with valid data updates a stock split" do
      split = split_fixture()
      attrs = %{ticker: "appl", reverse: true}

      assert {:ok, %Split{} = updated_split} = Investment.update_split(split, attrs)
      assert updated_split.ticker == String.upcase(attrs.ticker)
      assert updated_split.reverse == attrs.reverse
    end

    test "update_splt/2 with invalid data updates a stock split" do
      split = split_fixture()
      attrs = %{multiplier: -2}

      assert {:error, %Ecto.Changeset{}} = Investment.update_split(split, attrs)
    end

    test "change_split/1 returns a position changeset" do
      split = split_fixture()

      assert %Ecto.Changeset{} = Splits.change_split(split)
    end

    test "delete_split/1 deletes position" do
      split = split_fixture()

      assert {:ok, %Split{}} = Investment.delete_split(split)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Split, split.id) end
    end
  end
end

defmodule Profitry.Investment.SplitsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Schema.Split

  describe "split" do
    test "create_split/1 with valid data creates a stock split" do
      attrs = %{
        ticker: "aapl",
        multiple: "2",
        reverse: false,
        date: "2024-01-01"
      }

      assert {:ok, %Split{} = split} = Investment.create_split(attrs)
      assert split.ticker === String.upcase(attrs.ticker)
      assert Decimal.eq?(split.multiple, Decimal.new(attrs.multiple)) === true
      assert split.reverse === attrs.reverse
      assert split.date === Date.from_iso8601!(attrs.date)
      assert split === Repo.get!(Split, split.id)
    end

    test "create_split/1 with invalid data creates an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_split(%{})
    end

    test "list_splits/0 returns existing stock splits" do
      split = split_fixture()

      assert Investment.list_splits() === [split]
    end

    test "get_split!/1 returns existing stock split" do
      split = split_fixture()

      assert Investment.get_split!(split.id) === split
    end

    test "get_split/1 returns nil for invalid stock split id" do
      assert_raise Ecto.NoResultsError, fn -> Investment.get_split!(9999) end
    end

    test "find_splits/1 returns stock splits for a ticker" do
      split = split_fixture()
      {_portfolio, position} = position_fixture()

      assert Investment.find_splits(position) === [split]
    end

    test "find_splits/1 returns an empty list for a stock with no splits" do
      {_portfolio, position} = position_fixture()
      assert Investment.find_splits(position) === []
    end

    test "find_splits/1 finds splits across ticker changes" do
      # Create a position with current ticker
      portfolio = portfolio_fixture()
      position = position_fixture(portfolio, %{ticker: "TSLA"})
      split = split_fixture(%{ticker: "XPTO", date: ~D[2023-01-01]})
      ticker_change_fixture(%{ticker: "TSLA", original_ticker: "XPTO", date: ~D[2023-02-01]})

      assert Investment.find_splits(position) === [split]
    end

    test "find_splits/1 finds multiple splits across different ticker changes" do
      portfolio = portfolio_fixture()
      position = position_fixture(portfolio, %{ticker: "TSLA"})
      split1 = split_fixture(%{ticker: "OLD", date: ~D[2022-01-01]})
      split2 = split_fixture(%{ticker: "XPTO", date: ~D[2023-01-01]})
      split3 = split_fixture(%{ticker: "TSLA", date: ~D[2024-01-01]})
      ticker_change_fixture(%{ticker: "XPTO", original_ticker: "OLD", date: ~D[2022-06-01]})
      ticker_change_fixture(%{ticker: "TSLA", original_ticker: "XPTO", date: ~D[2023-06-01]})

      assert Investment.find_splits(position) === [split1, split2, split3]
    end

    test "find_splits/1 returns only relevant splits for position ticker" do
      portfolio1 = portfolio_fixture(%{broker: "IBKR1"})
      portfolio2 = portfolio_fixture(%{broker: "IBKR2"})
      position1 = position_fixture(portfolio1, %{ticker: "TSLA"})
      position2 = position_fixture(portfolio2, %{ticker: "AAPL"})
      tsla_split = split_fixture(%{ticker: "XPTO", date: ~D[2023-01-01]})
      split_fixture(%{ticker: "OLD_AAPL", date: ~D[2023-01-01]})
      ticker_change_fixture(%{ticker: "TSLA", original_ticker: "XPTO", date: ~D[2023-02-01]})

      assert Investment.find_splits(position1) === [tsla_split]
      assert Investment.find_splits(position2) === []
    end

    test "update_split/2 with valid data updates a stock split" do
      split = split_fixture()
      attrs = %{ticker: "appl", reverse: true}

      assert {:ok, %Split{} = updated_split} = Investment.update_split(split, attrs)
      assert updated_split.ticker === String.upcase(attrs.ticker)
      assert updated_split.reverse === attrs.reverse
    end

    test "update_split/2 with invalid data does not update a stock split" do
      split = split_fixture()
      attrs = %{multiple: -2}

      assert {:error, %Ecto.Changeset{}} = Investment.update_split(split, attrs)
    end

    test "change_split/1 returns a split changeset" do
      split = split_fixture()

      assert %Ecto.Changeset{} = Investment.change_split(split)
    end

    test "delete_split/1 deletes split" do
      split = split_fixture()

      assert {:ok, %Split{}} = Investment.delete_split(split)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Split, split.id) end
    end
  end
end

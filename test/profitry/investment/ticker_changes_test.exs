defmodule Profitry.Investment.TickerChangesTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Schema.TickerChange

  describe "ticker changes" do
    test "create_ticker_change/1 with valid data creates a ticker change" do
      attrs = %{
        ticker: "aapl",
        original_ticker: "aaaa",
        date: "2024-01-01"
      }

      assert {:ok, %TickerChange{} = ticker_change} = Investment.create_ticker_change(attrs)
      assert ticker_change.ticker === String.upcase(attrs.ticker)
      assert ticker_change.original_ticker === String.upcase(attrs.original_ticker)
      assert ticker_change.date === Date.from_iso8601!(attrs.date)
      assert ticker_change === Repo.get!(TickerChange, ticker_change.id)
    end

    test "create_ticker_change/1 with invalid data creates an error changeset" do
      assert {:error, %Ecto.Changeset{}} = Investment.create_ticker_change(%{})
    end

    test "list_ticker_changes/0 returns existing ticker changes" do
      ticker_change = ticker_change_fixture()

      assert Investment.list_ticker_changes() === [ticker_change]
    end

    test "get_ticker_changer!/1 returns existing ticker change" do
      ticker_change = ticker_change_fixture()

      assert Investment.get_ticker_change!(ticker_change.id) === ticker_change
    end

    test "get_ticker_change!/1 returns nil for invalid stock split id" do
      assert_raise Ecto.NoResultsError, fn -> Investment.get_ticker_change!(9999) end
    end

    test "update_ticker_change/2 with valid data updates a ticker change" do
      ticker_change = ticker_change_fixture()
      attrs = %{ticker: "bbbb", original_ticker: "aaaa"}

      assert {:ok, %TickerChange{} = updated_ticker_change} =
               Investment.update_ticker_change(ticker_change, attrs)

      assert updated_ticker_change.ticker === String.upcase(attrs.ticker)
      assert updated_ticker_change.original_ticker === String.upcase(attrs.original_ticker)
    end

    test "update_ticker_change/2 with invalid data does not update a ticker change" do
      ticker_change = ticker_change_fixture()
      attrs = %{ticker: "appl", original_ticker: "appl"}

      assert {:error, %Ecto.Changeset{}} = Investment.update_ticker_change(ticker_change, attrs)
    end

    test "change_ticker_change/1 returns a ticker_change changeset" do
      ticker_change = ticker_change_fixture()

      assert %Ecto.Changeset{} = Investment.change_ticker_change(ticker_change)
    end

    test "delete_ticker_change/1 deletes ticker change" do
      ticker_change = ticker_change_fixture()

      assert {:ok, %TickerChange{}} = Investment.delete_ticker_change(ticker_change)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(TickerChange, ticker_change.id) end
    end

    test "find_recent_ticker/1 finds the most up to date ticker" do
      first_ticker = "XXXX"
      ticker_change = ticker_change_fixture()

      Repo.insert!(%TickerChange{
        ticker: ticker_change.original_ticker,
        original_ticker: first_ticker,
        date: Date.add(ticker_change.date, -365)
      })

      assert Investment.find_recent_ticker(first_ticker) == ticker_change.ticker
      assert Investment.find_recent_ticker(ticker_change.original_ticker) == ticker_change.ticker
      assert Investment.find_recent_ticker(ticker_change.ticker) == ticker_change.ticker
    end

    test "fetch_historical_tickers/1 fetches all relevant tickers for a stock" do
      first_ticker = "XXXX"
      ticker_change = ticker_change_fixture()
      hist_tickers = [first_ticker, ticker_change.original_ticker, ticker_change.ticker]

      Repo.insert!(%TickerChange{
        ticker: ticker_change.original_ticker,
        original_ticker: first_ticker,
        date: Date.add(ticker_change.date, -365)
      })

      assert Investment.fetch_historical_tickers(first_ticker) === hist_tickers
      assert Investment.fetch_historical_tickers(ticker_change.original_ticker) === hist_tickers
      assert Investment.fetch_historical_tickers(ticker_change.ticker) === hist_tickers
    end

    test "find_position_by_ticker/2 finds the position for an historical ticker" do
      {portfolio, position1} = position_fixture()
      position2 = position_fixture(portfolio, %{ticker: "AAPL"})
      ticker_change = ticker_change_fixture()

      assert Investment.find_position_by_ticker([position1, position2], position2.ticker) ===
               position2

      assert Investment.find_position_by_ticker([position1, position2], position1.ticker) ===
               position1

      assert Investment.find_position_by_ticker(
               [position1, position2],
               ticker_change.original_ticker
             ) === position2

      assert Investment.find_position_by_ticker([position1, position2], ticker_change.ticker) ===
               position2
    end
  end
end

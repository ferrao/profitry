defmodule Profitry.Exchanges.Clients.Finnhub.FinnhubQuoteTest do
  use Profitry.DataCase, async: true

  alias Profitry.Exchanges.Clients.Finnhub.FinnhubQuote
  alias Profitry.Exchanges.Schema.Quote

  describe "finnhub" do
    test "price is required" do
      changeset = FinnhubQuote.changeset(%{})
      assert ["can't be blank"] = errors_on(changeset).c
    end

    test "price is has to be greater than zero" do
      error = "must be greater than 0"

      changeset1 = FinnhubQuote.changeset(%{c: 0})
      changeset2 = FinnhubQuote.changeset(%{c: -1})

      assert [^error] = errors_on(changeset1).c
      assert [^error] = errors_on(changeset2).c
    end

    test "timestamp is required" do
      changeset = FinnhubQuote.changeset(%{})
      assert ["can't be blank"] = errors_on(changeset).t
    end

    test "creates a new Quote" do
      ticker = "AAPL"

      data = %{
        c: 258.2,
        d: 2.93,
        dp: 1.1478,
        h: 258.21,
        l: 255.29,
        o: 255.49,
        pc: 255.27,
        t: 1_735_074_000
      }

      quote = FinnhubQuote.new(ticker, data)

      assert %Quote{} = quote
      assert quote.exchange === "FINNHUB"
      assert quote.ticker === ticker
      assert quote.price === Decimal.new("258.2")
      assert quote.timestamp === ~U[2024-12-24 21:00:00Z]
    end
  end
end

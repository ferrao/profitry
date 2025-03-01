defmodule Profitry.Import.Parsers.Ibkr.ParserTest do
  use ExUnit.Case, async: true

  import Profitry.ParsersFixtures

  alias Profitry.Import.Parsers.Ibkr.Parser
  alias Profitry.Import.Parsers.Schema.Trade

  @symbol1 "TSLA 19NOV21 1100.0 C"
  @symbol2 "SOFI 15JUL22 17.5 P"
  @symbol3 "DM"
  @symbol4 "CLOV"

  describe "ibkr symbol parser" do
    test "gets ticker from symbol" do
      assert "TSLA" === Parser.symbol_to_ticker(@symbol1)
      assert "SOFI" === Parser.symbol_to_ticker(@symbol2)
      assert "DM" === Parser.symbol_to_ticker(@symbol3)
      assert "CLOV" === Parser.symbol_to_ticker(@symbol4)
    end

    test "gets contract from symbol" do
      assert :call === Parser.symbol_to_contract(@symbol1)
      assert :put === Parser.symbol_to_contract(@symbol2)
    end

    test "gets strike from symbol" do
      assert Decimal.new("1100.0") === Parser.symbol_to_strike(@symbol1)
      assert Decimal.new("17.5") === Parser.symbol_to_strike(@symbol2)
    end

    test "gets expiration from symbol" do
      assert ~D[2021-11-19] === Parser.symbol_to_expiration(@symbol1)
      assert ~D[2022-07-15] === Parser.symbol_to_expiration(@symbol2)
    end
  end

  describe "ibkr trade parser" do
    @stock "Stocks"
    @option "Equity and Index Options"

    test "parses a stock trade" do
      assert %Trade{
               asset: :stock,
               currency: "USD",
               ticker: "DM",
               quantity: quantity,
               price: price,
               fees: fees,
               ts: ~N[2021-10-15 16:20:00],
               option: nil
             } =
               Parser.parse_trade(
                 @stock,
                 "USD",
                 @symbol3,
                 "3",
                 "10.2",
                 "-0.145",
                 "2021-10-15, 16:20:00"
               )

      assert quantity === Decimal.new("3")
      assert price === Decimal.new("10.2")
      assert fees === Decimal.new("0.145")
    end

    test "parses an option trade" do
      assert %Trade{
               asset: :option,
               currency: "USD",
               ticker: "TSLA",
               quantity: quantity,
               price: price,
               fees: fees,
               ts: ~N[2021-10-15 16:20:00],
               option: %{
                 contract: :call,
                 strike: strike,
                 expiration: ~D[2021-11-19]
               }
             } =
               Parser.parse_trade(
                 @option,
                 "USD",
                 @symbol1,
                 "3",
                 "10.2",
                 "-0.237",
                 "2021-10-15, 16:20:00"
               )

      assert quantity === Decimal.new("3")
      assert price === Decimal.new("10.2")
      assert strike === Decimal.new("1100.0")
      assert fees === Decimal.new("0.237")
    end
  end

  describe "ibkr activity statement parser" do
    test "parses an ibkr activity statement" do
      assert trades_fixture() === Parser.parse("test/support/csv/ibkr.csv")
    end
  end
end

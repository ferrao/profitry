defmodule Profitry.Import.TradesTest do
  use ExUnit.Case, async: true

  import Profitry.ParsersFixtures

  alias Profitry.Import.Trades
  alias Profitry.Import.Parsers.Schema.Trade
  alias Profitry.Investment.Schema.{Order, Option}

  @trade1 %Trade{
    asset: :stock,
    currency: "USD",
    ticker: "CLOV",
    quantity: Decimal.new("-100"),
    price: Decimal.new("5.69"),
    ts: ~N[2021-11-19 10:38:39],
    option: nil
  }

  @trade2 %Trade{
    asset: :option,
    currency: "USD",
    ticker: "SOFI",
    quantity: Decimal.new("1"),
    price: Decimal.new("1.8"),
    ts: ~N[2021-12-03 12:47:43],
    option: %{
      contract: :call,
      strike: Decimal.new("17.5"),
      expiration: ~D[2022-02-18]
    }
  }

  describe "trades" do
    test "convert trade with no option to order" do
      order = Trades.convert(@trade1)

      assert %Order{} = order
      assert order.type == :sell
      assert order.quantity == Decimal.new("100")
      assert order.instrument == @trade1.asset
      assert order.price == @trade1.price
      assert order.inserted_at == @trade1.ts
    end

    test "convert trade with option to order" do
      order = Trades.convert(@trade2)

      assert %Order{} = order
      assert %Option{} = order.option
      assert order.type == :buy
      assert order.quantity == @trade2.quantity
      assert order.instrument == @trade2.asset
      assert order.price == @trade2.price
      assert order.inserted_at == @trade2.ts

      assert order.option.type == @trade2.option.contract
      assert order.option.strike == @trade2.option.strike
      assert order.option.expiration == @trade2.option.expiration
    end
  end
end

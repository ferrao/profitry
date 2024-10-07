defmodule Profitry.Import.TradesTest do
  use ExUnit.Case, async: true

  alias Profitry.Import.Trades
  alias Profitry.Import.Parsers.Schema.Trade

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

      assert order.type == "sell"
      assert order.quantity == "100"
      assert order.instrument == "stock"
      assert order.price == to_string(@trade1.price)
      assert order.inserted_at == @trade1.ts |> NaiveDateTime.to_string()
    end

    test "convert trade with option to order" do
      order = Trades.convert(@trade2)

      assert order.type == "buy"
      assert order.quantity == "1"
      assert order.instrument == "option"
      assert order.price == to_string(@trade2.price)
      assert order.inserted_at == @trade2.ts |> NaiveDateTime.to_string()

      assert order.option.type == "call"
      assert order.option.strike == @trade2.option.strike |> Decimal.to_string()
      assert order.option.expiration == @trade2.option.expiration |> Date.to_string()
    end
  end
end

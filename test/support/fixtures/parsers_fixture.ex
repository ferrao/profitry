defmodule Profitry.ParsersFixtures do
  @moduledoc """

  This module defines test helpers for creating Profitry.Parsers context fixtures.

  """

  alias Profitry.Import.Parsers.Schema.Trade

  @doc """

  Generate a set of trades

  """
  def trades_fixture() do
    [
      %Trade{
        asset: :stock,
        currency: "USD",
        ticker: "CLOV",
        quantity: Decimal.new("100"),
        price: Decimal.new("5.69"),
        fees: Decimal.new("1"),
        ts: ~N[2021-11-19 10:38:39],
        option: nil
      },
      %Trade{
        asset: :stock,
        currency: "USD",
        ticker: "TSLA",
        quantity: Decimal.new("-100"),
        price: Decimal.new("1100"),
        fees: Decimal.new("0.5729"),
        ts: ~N[2021-11-19 16:20:00],
        option: nil
      },
      %Trade{
        asset: :option,
        currency: "USD",
        ticker: "SOFI",
        quantity: Decimal.new("1"),
        price: Decimal.new("1.8"),
        fees: Decimal.new("1.02135"),
        ts: ~N[2021-12-03 12:47:43],
        option: %{
          contract: :call,
          strike: Decimal.new("17.5"),
          expiration: ~D[2022-02-18]
        }
      },
      %Trade{
        asset: :option,
        currency: "USD",
        ticker: "SOFI",
        quantity: Decimal.new("-1"),
        price: Decimal.new("5.4"),
        fees: Decimal.new("1.026104"),
        ts: ~N[2021-12-03 12:46:50],
        option: %{
          contract: :put,
          strike: Decimal.new("17.5"),
          expiration: ~D[2022-07-15]
        }
      },
      %Trade{
        asset: :option,
        currency: "USD",
        ticker: "TSLA",
        quantity: Decimal.new("1"),
        price: Decimal.new("0"),
        fees: Decimal.new("0"),
        ts: ~N[2021-12-17 16:20:00],
        option: %{
          contract: :put,
          strike: Decimal.new("1100.0"),
          expiration: ~D[2021-12-17]
        }
      },
      %Trade{
        asset: :option,
        currency: "USD",
        ticker: "TSLA",
        quantity: Decimal.new("-1"),
        price: Decimal.new("14"),
        fees: Decimal.new("1.02049"),
        ts: ~N[2021-12-21 09:37:55],
        option: %{
          contract: :call,
          strike: Decimal.new("1100.0"),
          expiration: ~D[2022-01-21]
        }
      }
    ]
  end
end

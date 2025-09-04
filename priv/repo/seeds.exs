# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Profitry.Repo.insert!(%Profitry.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Profitry.Investment.Schema.Split
alias Profitry.Investment.Schema.TickerChange

Profitry.Repo.delete_all(Split)

Profitry.Repo.insert!(%Split{
  ticker: "TSLA",
  multiple: 5,
  reverse: false,
  date: ~D[2020-08-31]
})

Profitry.Repo.insert!(%Split{
  ticker: "TSLA",
  multiple: 3,
  reverse: false,
  date: ~D[2022-08-25]
})

Profitry.Repo.insert!(%Split{
  ticker: "PSFE",
  multiple: 12,
  reverse: true,
  date: ~D[2022-12-13]
})

Profitry.Repo.insert!(%Split{
  ticker: "SKLZ",
  multiple: 20,
  reverse: true,
  date: ~D[2023-06-26]
})

Profitry.Repo.insert!(%Split{
  ticker: "VLD",
  multiple: 35,
  reverse: true,
  date: ~D[2024-06-11]
})

Profitry.Repo.insert!(%Split{
  ticker: "VLDX",
  multiple: 15,
  reverse: true,
  date: ~D[2025-07-28]
})

Profitry.Repo.insert!(%Split{
  ticker: "MILE",
  multiple: 19,
  reverse: true,
  date: ~D[2022-07-28]
})

Profitry.Repo.insert!(%Split{
  ticker: "LTHM",
  multiple: 2.406,
  reverse: false,
  date: ~D[2024-01-04]
})

Profitry.Repo.insert!(%Split{
  ticker: "UNG",
  multiple: 4,
  reverse: true,
  date: ~D[2024-01-24]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "UNG",
  original_ticker: "UNG1",
  date: ~D[2024-01-24]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "PTRAQ",
  original_ticker: "PTRA",
  date: ~D[2023-08-17]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "LMND",
  original_ticker: "MILE",
  date: ~D[2023-07-28]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "APPHQ",
  original_ticker: "APPH",
  date: ~D[2023-08-02]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "ALTM",
  original_ticker: "LTHM",
  date: ~D[2024-01-04]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "CSGP",
  original_ticker: "MTTR",
  date: ~D[2025-02-28]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "VLDX",
  original_ticker: "VLD",
  date: ~D[2024-09-11]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "VLDXD",
  original_ticker: "VLDX",
  date: ~D[2025-07-28]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "VELO",
  original_ticker: "VLDXD",
  date: ~D[2025-08-19]
})

Profitry.Repo.insert!(%TickerChange{
  ticker: "XYZ",
  original_ticker: "SQ",
  date: ~D[2025-01-21]
})

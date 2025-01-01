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

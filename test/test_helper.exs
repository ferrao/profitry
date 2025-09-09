# Annotate tests with @tag :skip to exclude them from running
ExUnit.start(exclude: [:skip])
Ecto.Adapters.SQL.Sandbox.mode(Profitry.Repo, :manual)

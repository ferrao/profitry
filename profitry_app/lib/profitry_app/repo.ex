defmodule ProfitryApp.Repo do
  use Ecto.Repo,
    otp_app: :profitry_app,
    adapter: Ecto.Adapters.Postgres
end

defmodule Profitry.Repo do
  use Ecto.Repo,
    otp_app: :profitry,
    adapter: Ecto.Adapters.Postgres
end

defmodule Profitry.Server.Repo do
  use Ecto.Repo,
    otp_app: :profitry_server,
    adapter: Ecto.Adapters.Postgres
end

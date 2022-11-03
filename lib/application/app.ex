defmodule Profitry.Application.App do
  alias Profitry.Application.Server

  use Application

  def start(_type, _args) do
    Server.start()
  end
end

defmodule Profitry.Runtime.App do
  alias Profitry.Runtime.Server

  use Application

  @sup_name ProfitryStarter

  def start(_type, _args) do
    supervisor = [
      {DynamicSupervisor, strategy: :one_for_one, name: @sup_name}
    ]

    Supervisor.start_link(supervisor, strategy: :one_for_one)
  end

  def start_server do
    DynamicSupervisor.start_child(@sup_name, {Server, nil})
  end
end

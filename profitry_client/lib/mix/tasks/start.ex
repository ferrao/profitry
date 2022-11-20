defmodule Mix.Tasks.Start do
  use Mix.Task

  def run(_) do
    :net_kernel.start([:client, :shortnames])
    ProfitryClient.start()
  end
end

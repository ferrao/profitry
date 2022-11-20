defmodule Profitry.Application.Clock do
  @spec now() :: integer()
  def now(), do: System.system_time(:second)
end

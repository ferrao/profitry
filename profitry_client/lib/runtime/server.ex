defmodule ProfitryClient.Runtime.Server do
  @node :profitry@z13

  def connect do
    :rpc.call(@node, Profitry, :start_server, [])
  end
end

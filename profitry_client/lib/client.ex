defmodule ProfitryClient do
  alias ProfitryClient.Application.Server
  alias ProfitryClient.Ui.Portfolio

  @spec start() :: any()
  def start do
    Server.connect()
    |> Portfolio.List.render()
  end
end

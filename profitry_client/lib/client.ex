defmodule ProfitryClient do
  alias ProfitryClient.Application.Server
  alias ProfitryClient.Ui.Home

  def start do
    Server.connect()
    |> Home.render()
  end
end

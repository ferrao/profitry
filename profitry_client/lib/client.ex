defmodule ProfitryClient do
  alias ProfitryClient.Application.Server
  alias ProfitryClient.Ui.Portfolios

  def start do
    Server.connect()
    |> Portfolios.render()
  end
end

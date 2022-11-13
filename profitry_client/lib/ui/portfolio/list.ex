defmodule ProfitryClient.Ui.Portfolio.List do
  alias ProfitryClient.Ui.Commons
  alias ProfitryClient.Ui.Portfolio.{Create, Details}

  def render(server) do
    "List of Portfolios: \n"
    |> Commons.green()
    |> IO.puts()

    options =
      [
        %{id: :create, value: "Create a new Portfolio"}
        | portfolios_options(server)
      ] ++ [%{id: :quit, value: "Quit"}]

    Commons.select(options)
    |> render(server)
  end

  def render(%{id: :create}, server) do
    Create.render(server)
    render(server)
  end

  def render(%{id: :quit}, _server) do
    "Bye!"
    |> Commons.green()
    |> IO.puts()
  end

  def render(option, server) do
    Profitry.get_portfolio(server, option.id)
    |> Details.render(server)

    render(server)
  end

  defp portfolios_options(server) do
    portfolios = Profitry.list_portfolios(server)

    portfolios
    |> Keyword.keys()
    |> Enum.map(fn k -> %{id: k, value: portfolios[k]} end)
  end
end

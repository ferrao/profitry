defmodule ProfitryClient.Ui.Portfolio.List do
  alias ProfitryClient.Ui.Commons.{Colors, Select, Input}
  alias ProfitryClient.Ui.Portfolio.{Create, Details}

  def render(server) do
    "List of Portfolios: \n"
    |> Colors.green()
    |> IO.puts()

    options =
      [%{id: :create, value: "Create a new Portfolio"} | portfolios_options(server)] ++
        [
          %{id: :load, value: "Load a Portfolio"},
          %{id: :save, value: "Save a Portfolio"},
          %{id: :quit, value: "Quit"}
        ]

    Select.render(options)
    |> render(server)
  end

  def render(%{id: :save}, server) do
    path = Input.File.render()
    Profitry.save(server, path)

    render(server)
  end

  def render(%{id: :load}, server) do
    path = Input.File.render()
    Profitry.load(server, path)

    render(server)
  end

  def render(%{id: :create}, server) do
    Create.render(server)
    render(server)
  end

  def render(%{id: :quit}, _server) do
    "Bye!"
    |> Colors.green()
    |> IO.puts()
  end

  def render(option, server) do
    Profitry.get_portfolio(server, option.id)
    |> Details.render(server)

    render(server)
  end

  defp portfolios_options(server) do
    portfolios =
      Profitry.list_portfolios(server)
      |> IO.inspect()

    portfolios
    |> Enum.map(fn {id, name} -> %{id: id, value: name} end)
  end
end

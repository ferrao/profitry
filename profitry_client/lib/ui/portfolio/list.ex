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
    save_result = Profitry.save(server, path)

    if :error == save_result do
      Colors.red("Unable to save to #{path} \n\n") |> IO.puts()
    end

    render(server)
  end

  def render(%{id: :load}, server) do
    path = Input.File.render()
    load_result = Profitry.load(server, path)

    if :error == load_result do
      Colors.red("Unable to load from #{path} \n\n") |> IO.puts()
    end

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
    Profitry.list_portfolios(server)
    |> Enum.map(fn {id, name} -> %{id: id, value: name} end)
  end
end

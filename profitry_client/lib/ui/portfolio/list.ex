defmodule ProfitryClient.Ui.Portfolio.List do
  alias Profitry.Domain.Portfolio
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

    Owl.IO.select(options, render_as: &Commons.render_option/1)
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
    Details.render(%Portfolio{id: option.id, name: option.value}, server)
    render(server)
  end

  defp portfolios_options(server) do
    portfolios = Profitry.list_portfolios(server)

    portfolios
    |> Keyword.keys()
    |> Enum.map(fn k -> %{id: k, value: portfolios[k]} end)
  end
end

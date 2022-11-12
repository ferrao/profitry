defmodule ProfitryClient.Ui.Portfolios do
  def render(server) do
    "List of Portfolios: \n"
    |> green
    |> IO.puts()

    options =
      [
        %{id: :create, value: "Create a new Portfolio"}
        | portfolios_options(server)
      ] ++ [%{id: :quit, value: "Quit"}]

    Owl.IO.select(options, render_as: fn option -> option.value end)
    |> render(server)
  end

  def render(%{id: :create}, server) do
    id =
      Owl.IO.input(label: "Portfolio ID?", cast: string_validator(1, 4))
      |> String.downcase()
      |> String.to_atom()

    name = Owl.IO.input(label: "Portfolio Name?", cast: string_validator(2, 80))

    Profitry.new_portfolio(server, id, name)
    render(server)
  end

  def render(%{id: :quit}, _server) do
    "Bye!"
    |> green()
    |> IO.puts()
  end

  def cast_input(%{size: size, min: min}) when size < min do
    {:error, "lenght must be greater than or equal to #{min}"}
  end

  def cast_input(%{size: size, max: max}) when size > max do
    {:error, "lenght must be smaller than or equal to #{max}"}
  end

  def cast_input(%{value: value}) do
    {:ok, value}
  end

  def string_validator(min, max) do
    fn str ->
      cast_input(%{
        value: str,
        size: String.length(str),
        min: min,
        max: max
      })
    end
  end

  defp green(string) do
    string
    |> Owl.Data.tag(:green)
    |> Owl.Data.to_ansidata()
  end

  defp portfolios_options(server) do
    portfolios = Profitry.list_portfolios(server)

    portfolios
    |> Keyword.keys()
    |> Enum.map(fn k -> %{id: k, value: portfolios[k]} end)
  end
end

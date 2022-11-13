defmodule ProfitryClient.Ui.Portfolio.Create do
  def render(server) do
    id =
      Owl.IO.input(label: "Portfolio ID?", cast: string_validator(1, 4))
      |> String.downcase()
      |> String.to_atom()

    name = Owl.IO.input(label: "Portfolio Name?", cast: string_validator(2, 80))

    Profitry.new_portfolio(server, id, name)
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
end

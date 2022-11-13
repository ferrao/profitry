defmodule ProfitryClient.Ui.Position.Create do
  alias ProfitryClient.Ui.Commons

  def render(server) do
    options = [
      %{id: :create, value: "Create a new position"},
      %{id: :back, value: "Go Back"}
    ]

    Owl.IO.select(options, render_as: &Commons.render_option/1)
    |> render(server)
  end

  def render(%{id: :create}, server) do
    render(server)
  end

  def render(_, _server) do
  end
end

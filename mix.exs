defmodule Profitry.MixProject do
  use Mix.Project

  def project do
    [
      app: :profitry,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Profitry.Application.App, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:decimal, "~> 2.0.0"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end

defmodule Profitry.MixProject do
  use Mix.Project

  def project do
    [
      app: :profitry_server,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # set compile path
      elixirc_paths:
        case Mix.env() do
          :test -> ["lib", "test/lib"]
          _ -> ["lib"]
        end
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
      {:poison, "~> 5.0"},

      # Dev deps
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}

      # Test deps
    ]
  end
end

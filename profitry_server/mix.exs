defmodule Profitry.MixProject do
  use Mix.Project

  def project do
    [
      app: :profitry_server,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Profitry.Runtime.App, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/lib"]
  defp elixirc_paths(_), do: ["lib"]

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

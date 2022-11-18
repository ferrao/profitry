defmodule ProfitryCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :profitry_cli,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      included_applications: [:profitry_core],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:profitry_server, path: "../profitry_server"},
      {:owl, "~> 0.4"},
      {:table_rex, "~> 3.1.1"},

      # Dev Deps
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end

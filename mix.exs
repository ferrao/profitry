defmodule Profitry.MixProject do
  use Mix.Project

  def project do
    [
      app: :profitry,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:decimal, "~> 2.0.0"}
    ]
  end
end

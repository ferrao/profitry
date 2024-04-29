defmodule Profitry.Investment.Schema.PositionReport do
  @moduledoc """

  Schema representing a report for a portfolio position

  """

  alias Profitry.Investment.Schema.OptionsReport

  @type t :: %__MODULE__{
          ticker: String.t(),
          investment: Decimal.t(),
          shares: Decimal.t(),
          cost_basis: Decimal.t(),
          price: Decimal.t(),
          value: Decimal.t(),
          profit: Decimal.t(),
          long_options: list(OptionsReport.t()),
          short_options: list(OptionsReport.t())
        }

  defstruct [
    :ticker,
    investment: Decimal.new(0),
    shares: Decimal.new(0),
    cost_basis: Decimal.new(0),
    price: Decimal.new(0),
    value: Decimal.new(0),
    profit: Decimal.new(0),
    long_options: [],
    short_options: []
  ]

  @doc """

  Calculates the cost basis for a position report

  """
  # with no shares
  def calculate_cost_basis(report, _has_shares = false) do
    Map.put(report, :cost_basis, "0.00")
  end

  # with shares
  def calculate_cost_basis(report, _has_shares) do
    Map.put(report, :cost_basis, Decimal.div(report.investment, report.shares))
  end

  @doc """

  Calculates the profit on a position report

  """
  # with no quote
  def calculate_profit(report, nil) do
    Map.put(report, :profit, Decimal.new(0))
  end

  # with a quote
  def calculate_profit(report, price) do
    profit =
      Decimal.mult(report.shares, price)
      |> Decimal.sub(report.investment)

    Map.put(report, :price, price)
    |> Map.put(:profit, profit)
  end

  # with no quote
  def calculate_value(report, nil) do
    Map.put(report, :value, Decimal.new(0))
  end

  # with quote
  def calculate_value(report, price) do
    Map.put(report, :value, Decimal.mult(report.shares, price))
  end
end

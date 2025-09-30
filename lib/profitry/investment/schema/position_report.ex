defmodule Profitry.Investment.Schema.PositionReport do
  @moduledoc """

  Schema representing a report for a portfolio position

  """

  alias __MODULE__
  alias Profitry.Investment.Schema.OptionsReport

  @type t :: %__MODULE__{
          id: integer(),
          ticker: String.t(),
          investment: Decimal.t(),
          fees: Decimal.t(),
          shares: Decimal.t(),
          cost_basis: Decimal.t(),
          price: Decimal.t(),
          value: Decimal.t(),
          profit: Decimal.t(),
          delisted?: boolean(),
          delisting_payout: Decimal.t(),
          long_options: list(OptionsReport.t()),
          short_options: list(OptionsReport.t())
        }

  defstruct [
    :id,
    :ticker,
    investment: Decimal.new(0),
    fees: Decimal.new(0),
    shares: Decimal.new(0),
    cost_basis: Decimal.new(0),
    price: Decimal.new(0),
    value: Decimal.new(0),
    profit: Decimal.new(0),
    delisted?: false,
    delisting_payout: Decimal.new(0),
    long_options: [],
    short_options: []
  ]

  @doc """

  Calculates the cost basis for a position report

  """
  # with no shares
  @spec calculate_cost_basis(t(), boolean()) :: t()
  def calculate_cost_basis(report, _has_shares = false) do
    Map.put(report, :cost_basis, Decimal.new(0))
  end

  # with shares
  @spec calculate_cost_basis(t(), boolean()) :: t()
  def calculate_cost_basis(report, _has_shares) do
    cost_basis = Decimal.div(report.investment, report.shares)
    Map.put(report, :cost_basis, cost_basis)
  end

  @doc """

  Calculates the profit on a position report

  """

  # delisted no quote
  @spec calculate_profit(t(), nil) :: t()
  def calculate_profit(%PositionReport{delisted?: true} = report, nil) do
    profit = calculate_profit_delisted(report)
    Map.put(report, :profit, profit)
  end

  # delisted with quote
  @spec calculate_profit(t(), Decimal.t()) :: t()
  def calculate_profit(%PositionReport{delisted?: true} = report, price) do
    profit = calculate_profit_delisted(report)

    Map.put(report, :price, price)
    |> Map.put(:profit, profit)
  end

  # with no quote
  @spec calculate_profit(t(), nil) :: t()
  def calculate_profit(report, nil) do
    if Decimal.eq?(report.shares, 0) do
      # Without shares, p/l is -investment
      Map.put(report, :profit, Decimal.negate(report.investment))
    else
      Map.put(report, :profit, Decimal.new(0))
    end
  end

  # with quote
  @spec calculate_profit(t(), Decimal.t()) :: t()
  def calculate_profit(report, price) do
    profit =
      Decimal.mult(report.shares, price)
      |> Decimal.sub(report.investment)

    Map.put(report, :price, price)
    |> Map.put(:profit, profit)
  end

  @doc false
  defp calculate_profit_delisted(report) do
    payout = Decimal.mult(report.delisting_payout, report.shares)

    Decimal.negate(report.investment)
    |> Decimal.add(payout)
  end

  @doc """

  Calculates the value of a position report

  """
  # delisted
  @spec calculate_value(t(), Decimal.t() | nil) :: t()
  def calculate_value(%PositionReport{delisted?: true} = report, _price) do
    Map.put(report, :value, Decimal.new(0))
  end

  # with no quote
  @spec calculate_value(t(), nil) :: t()
  def calculate_value(report, nil) do
    Map.put(report, :value, Decimal.new(0))
  end

  # with quote
  @spec calculate_value(t(), Decimal.t()) :: t()
  def calculate_value(report, price) do
    Map.put(report, :value, Decimal.mult(report.shares, price))
  end
end

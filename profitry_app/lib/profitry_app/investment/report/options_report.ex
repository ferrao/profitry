defmodule ProfitryApp.Investment.Report.OptionsReport do
  @moduledoc """

  Struct representing a report on a set of options contracts for a position report

  """
  alias ProfitryApp.Exchanges.Quote

  @type t :: %__MODULE__{
          strike: Integer.t(),
          expiration: Date.t(),
          contracts: Integer.t(),
          value: Decimal.t()
        }

  defstruct [
    :strike,
    :expiration,
    contracts: 1,
    value: 0
  ]

  @shares_per_contract 100

  @doc """

  Calculates the total value of an options report based on an price quote

  """
  @spec calculate_value(OptionsReport.t(), nil) :: OptionsReport.t()
  def calculate_value(report = %__MODULE__{}, nil) do
    Map.put(report, :value, 0)
  end

  @spec calculate_value(OptionsReport.t(), nil) :: OptionsReport.t()
  def calculate_value(report = %__MODULE__{}, quote = %Quote{}) do
    Map.put(report, :value, Decimal.mult(report.contracts * @shares_per_contract, quote.price))
  end

  @doc """

  Adds or updates a list of option reports with a new set of options contracts

  """
  @spec update_reports(list(OptionsReport.t()), OptionsReport.t()) :: list(OptionsReport.t())
  def update_reports([], options_report), do: [options_report]

  @spec update_reports(list(OptionsReport.t()), OptionsReport.t()) :: list(OptionsReport.t())
  def update_reports(
        [h = %{strike: strike, expiration: expiration, contracts: contracts} | t],
        %__MODULE__{strike: strike, expiration: expiration, contracts: new_contracts}
      ) do
    [%__MODULE__{h | contracts: contracts + new_contracts} | t]
  end

  @spec update_reports(list(OptionsReport.t()), OptionsReport.t()) :: list(OptionsReport.t())
  def update_reports([h | t], options_report), do: [h | update_reports(t, options_report)]
end

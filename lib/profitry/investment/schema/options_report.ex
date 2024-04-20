defmodule Profitry.Investment.Schema.OptionsReport do
  @moduledoc """

  Schema representing a report on a set of options contracts for a position report

  """

  @type t :: %__MODULE__{
          strike: Integer.t(),
          expiration: Date.t(),
          contracts: Integer.t(),
          value: Decimal.t()
        }

  defstruct [:strike, :expiration, contracts: 1, value: 0]

  @doc """

  Adds or updates a list of option reports with a new set of options contracts

  """
  @spec update_reports(list(OptionsReport.t()), OptionsReport.t()) :: list(OptionsReport.t())
  def update_reports([], options_report), do: [options_report]

  @spec update_reports(list(OptionsReport.t()), OptionsReport.t()) :: list(OptionsReport.t())
  def update_reports(
        [%__MODULE__{strike: strike, expiration: expiration, contracts: contracts} = h | t],
        %__MODULE__{strike: strike, expiration: expiration, contracts: new_contracts}
      ) do
    [%__MODULE__{h | contracts: contracts + new_contracts} | t]
  end

  @spec update_reports(list(OptionsReport.t()), OptionsReport.t()) :: list(OptionsReport.t())
  def update_reports([h | t], options_report), do: [h | update_reports(t, options_report)]
end

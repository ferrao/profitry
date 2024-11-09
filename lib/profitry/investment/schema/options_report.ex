defmodule Profitry.Investment.Schema.OptionsReport do
  @moduledoc """

  Schema representing a report on a set of options contracts for a position report

  """

  alias Profitry.Investment.Schema.Option

  @type t :: %__MODULE__{
          investment: Decimal.t(),
          type: Option.contract_type(),
          strike: integer(),
          expiration: Date.t(),
          contracts: integer()
        }

  defstruct [:strike, :expiration, investment: Decimal.new(0), type: :call, contracts: 1]

  @doc """

  Adds or updates a list of option reports with a new set of options contracts

  """
  @spec update_reports(list(t()), t()) :: list(t())
  def update_reports([], options_report), do: [options_report]

  @spec update_reports(list(t()), t()) :: list(t())
  def update_reports(
        [
          %__MODULE__{
            type: type,
            strike: strike,
            expiration: expiration,
            contracts: contracts,
            investment: investment
          } = h
          | t
        ],
        %__MODULE__{
          type: type,
          strike: strike,
          expiration: expiration,
          contracts: new_contracts,
          investment: new_investment
        }
      ) do
    [
      %__MODULE__{
        h
        | investment: Decimal.add(investment, new_investment),
          contracts: Decimal.add(contracts, new_contracts)
      }
      | t
    ]
  end

  @spec update_reports(list(t()), t()) :: list(t())
  def update_reports([h | t], options_report), do: [h | update_reports(t, options_report)]
end

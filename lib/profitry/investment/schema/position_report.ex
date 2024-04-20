defmodule Profitry.Investment.Schema.PositionReport do
  @moduledoc """

  Schema representing a report for a portfolio position

  """

  alias Profitry.Investment.Schema.OptionsReport

  @type t :: %__MODULE__{
          ticker: String.t(),
          investment: String.t(),
          shares: String.t(),
          cost_basis: String.t(),
          price: String.t(),
          value: String.t(),
          profit: String.t(),
          long_options: list(OptionsReport.t()),
          short_options: list(OptionsReport.t())
        }

  defstruct [
    :ticker,
    investment: 0,
    shares: 0,
    cost_basis: 0,
    price: 0,
    value: 0,
    profit: 0,
    long_options: [],
    short_options: []
  ]
end

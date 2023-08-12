defmodule ProfitryApp.Investment.Report do
  @moduledoc """

  Report for a portfolio position

  """

  alias ProfitryApp.Investment.Report

  @type t :: %__MODULE__{
          ticker: String.t(),
          investment: String.t(),
          shares: String.t(),
          cost_basis: String.t(),
          price: String.t(),
          value: String.t(),
          profit: String.t(),
          position_id: Integer.t(),
          long_options: list(OptionsReport.t()),
          short_options: list(OptionsReport.t())
        }

  defstruct [
    :position_id,
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

  defdelegate make_report(position, quote), to: Report.PositionReport
end

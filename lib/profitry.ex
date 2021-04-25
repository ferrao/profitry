defmodule Profitry do
  alias Profitry.{Position, Report}

  defdelegate new_position(ticker, order), to: Position
  defdelegate make_order(position, order), to: Position
  defdelegate make_report(position), to: Report
end

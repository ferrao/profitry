defmodule Profitry.Import do
  @moduledoc """

  The Import Context, responsible for importing positions from broker statements

  """

  alias Profitry.Import.File

  defdelegate process(portfolio_id, file), to: File
end

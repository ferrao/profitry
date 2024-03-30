defmodule Profitry.Investment do
  alias Profitry.Investment.Portfolios

  @moduledoc """

    The Investment Context

  """

  defdelegate create_portfolio(attrs), to: Portfolios
  defdelegate list_portfolios(), to: Portfolios
  defdelegate get_portfolio(id), to: Portfolios
  defdelegate update_portfolio(portfolio, attrs), to: Portfolios
  defdelegate delete_portfolio(portfolio), to: Portfolios
end

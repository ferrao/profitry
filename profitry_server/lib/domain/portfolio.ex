defmodule Profitry.Domain.Portfolio do
  alias Profitry.Domain.{Portfolio, Position, Report, StockOrder, OptionsOrder}

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          positions: %{atom() => Position.t()}
        }

  defstruct(
    id: nil,
    name: nil,
    positions: %{}
  )

  # Creates a new empty portfolio
  @spec new_portfolio(String.t(), String.t()) :: Portfolio.t()
  def new_portfolio(id, name) do
    %Portfolio{id: id, name: name}
  end

  # Creates a portfolio report
  @spec make_report(Portfolio.t()) :: list(Report.t())
  def make_report(%Portfolio{positions: positions}) do
    for {_ticker, position} <- positions do
      position
      |> Report.make_report()
    end
  end

  # Makes a new order in a portfolio position
  @spec make_order(Portfolio.t(), String.t(), StockOrder.t() | OptionsOrder.t()) :: Portfolio.t()
  def make_order(portfolio = %Portfolio{positions: positions}, ticker, order) do
    position = positions[ticker_key(ticker)]
    make_position_order(portfolio, ticker, order, position == nil)
  end

  # Adds a new position to a portfolio
  defp make_position_order(
         portfolio = %Portfolio{positions: positions},
         ticker,
         order,
         new_position
       )
       when new_position == true do
    position = Position.new_position(ticker, order)

    %Portfolio{portfolio | positions: Map.put(positions, ticker_key(ticker), position)}
  end

  # Adds an order to an existing portfolio position
  defp make_position_order(
         portfolio = %Portfolio{positions: positions},
         ticker,
         order,
         _new_position
       ) do
    positions =
      Map.put(
        positions,
        ticker_key(ticker),
        Position.make_order(positions[ticker_key(ticker)], order)
      )

    %Portfolio{portfolio | positions: positions}
  end

  defp ticker_key(ticker) do
    ticker
    |> String.upcase()
    |> String.to_atom()
  end
end

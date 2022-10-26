defmodule Profitry.Portfolio do
  alias Profitry.{Portfolio, Position, Report}

  @type t :: %__MODULE__{
          id: atom(),
          description: String.t(),
          positions: Map.t(Position.t())
        }

  defstruct(
    id: nil,
    description: nil,
    positions: %{}
  )

  # Creates a new empty portfolio
  def new_portfolio(id, description) do
    %Portfolio{id: id, description: description}
  end

  # Creates a portfolio report
  def make_report(%Portfolio{positions: positions}) do
    for {_ticker, position} <- positions do
      position
      |> Report.make_report()
    end
  end

  # Makes a new order in a portfolio position
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

  # Adds an order to am existing portfolio position
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

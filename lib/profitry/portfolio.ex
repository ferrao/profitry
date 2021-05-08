defmodule Profitry.Portfolio do
  alias Profitry.{Portfolio, Position}

  defstruct(
    id: nil,
    description: nil,
    positions: %{}
  )

  # Creates a new empty portfolio
  def new_portfolio(id, description) do
    %Portfolio{id: id, description: description}
  end

  # Adds a new position to a portfolio
  def new_position(portfolio = %Portfolio{positions: positions}, ticker, order) do
    position = Position.new_position(ticker, order)

    %Portfolio{portfolio | positions: Map.put(positions, ticker_key(ticker), position)}
  end

  # Adds an order to a portfolio position
  def make_order(portfolio = %Portfolio{positions: positions}, ticker, order) do
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

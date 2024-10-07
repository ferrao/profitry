defmodule Profitry.Import do
  alias Profitry.Investment.Schema.Portfolio
  alias Profitry.Import.Trades
  alias Profitry.Import.Parsers.Ibkr.Parser
  alias Profitry.Investment

  def process_file(file, name, description) do
    {:ok, portfolio} = Investment.create_portfolio(%{broker: name, description: description})
    trades = Parser.parse(file)

    create_positions(portfolio, trades)
    %Portfolio{positions: positions} = Profitry.Repo.preload(portfolio, :positions)

    trades
    |> Enum.map(&Trades.convert/1)
    |> Enum.each(fn order -> insert_order(positions, order) end)
  end

  defp create_positions(portfolio, trades) do
    Enum.map(trades, fn trade -> trade.ticker end)
    |> Enum.uniq()
    |> Enum.each(fn ticker -> Investment.create_position(portfolio, %{ticker: ticker}) end)
  end

  defp insert_order(positions, attrs) do
    position = Enum.find(positions, fn position -> position.ticker == attrs.ticker end)

    Investment.create_order(position, attrs)
  end
end

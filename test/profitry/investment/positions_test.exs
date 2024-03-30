defmodule Profitry.Investment.PositionsTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  alias Profitry.Investment.Schema.Position

  describe "position" do
    test "create_position/2 with valid data creates a position" do
      portfolio = portfolio_fixture()
      attrs = %{ticker: "aapl"}

      assert {:ok, %Position{} = position} = Investment.create_position(portfolio, attrs)
      assert position.ticker == String.upcase(attrs.ticker)
      assert position.portfolio_id == portfolio.id
      assert position == Repo.get!(Position, position.id) |> Repo.preload(:portfolio)
    end

    test "create_position/2 with invalid data creates an error changeset" do
      portfolio = portfolio_fixture()

      assert {:error, %Ecto.Changeset{}} = Investment.create_position(portfolio, %{})
    end
  end
end

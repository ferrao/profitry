defmodule ProfitryWeb.PositionLiveTest do
  use ProfitryWeb.ConnCase

  import Phoenix.LiveViewTest
  import Profitry.InvestmentFixtures

  # @create_attrs %{broker: "BROKER", description: "desc"}
  # @update_attrs %{broker: "BROKER", description: "new desc"}
  # @invalid_attrs %{broker: "BROKER", description: ""}

  defp create_position(_) do
    {portfolio, position} = position_fixture()
    %{portfolio: portfolio, position: position}
  end

  describe "Positions" do
    setup [:create_position]

    test "lists all positions for a portfolio", %{
      conn: conn,
      portfolio: portfolio,
      position: position
    } do
      {:ok, _index_live, html} = live(conn, ~p"/portfolios/#{portfolio.id}")

      assert html =~ "Listing Positions"
      assert html =~ portfolio.broker
      assert html =~ portfolio.description
      assert html =~ position.ticker
    end
  end
end

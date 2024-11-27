defmodule ProfitryWeb.PositionLiveTest do
  use ProfitryWeb.ConnCase

  import Phoenix.LiveViewTest
  import Profitry.InvestmentFixtures

  @create_attrs %{ticker: "SOFI"}
  @update_attrs %{ticker: "CLOV"}
  @invalid_attrs %{ticker: ""}

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
      {:ok, _position_live, html} = live(conn, ~p"/portfolios/#{portfolio.id}")

      assert html =~ "Listing Positions"
      assert html =~ portfolio.broker
      assert html =~ portfolio.description
      assert html =~ position.ticker
    end

    test "saves new position", %{conn: conn, portfolio: portfolio} do
      {:ok, position_live, _html} = live(conn, ~p"/portfolios/#{portfolio.id}")

      assert position_live
             |> element("a", "New Position")
             |> render_click() =~ "Save Position"

      assert_patch(position_live, ~p"/portfolios/#{portfolio.id}/positions/new")

      assert position_live
             |> form("#position-form", position: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert position_live
             |> form("#position-form", position: @create_attrs)
             |> render_submit()

      assert_patch(position_live, ~p"/portfolios/#{portfolio.id}")

      html = render(position_live)
      assert html =~ "Position created successfully"
    end

    test "updates existing position", %{conn: conn, portfolio: portfolio, position: position} do
      {:ok, position_live, _html} = live(conn, ~p"/portfolios/#{portfolio.id}")

      assert position_live
             |> element("#reports-#{position.id} a", "Edit")
             |> render_click() =~ "Edit Position"

      assert_patch(
        position_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/edit"
      )

      assert position_live
             |> form("#position-form", position: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert position_live
             |> form("#position-form", position: @update_attrs)
             |> render_submit()

      assert_patch(position_live, ~p"/portfolios/#{portfolio.id}")

      html = render(position_live)
      assert html =~ "Position updated successfully"
    end

    test "deletes an existing position", %{conn: conn, portfolio: portfolio, position: position} do
      {:ok, position_live, _html} = live(conn, ~p"/portfolios/#{portfolio.id}")

      assert position_live
             |> element("#reports-#{position.id} a", "Delete")
             |> render_click()

      refute has_element?(position_live, "#reports-#{position.id}")
    end

    test "deleting an existing position updates totals", %{
      conn: conn,
      portfolio: portfolio,
      position: position
    } do
      {:ok, position_live, html} = live(conn, ~p"/portfolios/#{portfolio.id}")

      assert position_live
             |> element("#reports-#{position.id} a", "Delete")
             |> render_click()

      ## Assert updated totals
    end
  end
end

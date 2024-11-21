defmodule ProfitryWeb.PortfolioLiveTest do
  use ProfitryWeb.ConnCase

  import Phoenix.LiveViewTest
  import Profitry.InvestmentFixtures

  @create_attrs %{broker: "BROKER", description: "desc"}
  @update_attrs %{broker: "BROKER", description: "new desc"}
  @invalid_attrs %{broker: "BROKER", description: ""}

  defp create_portfolio(_) do
    portfolio = portfolio_fixture()
    %{portfolio: portfolio}
  end

  describe "Index" do
    setup [:create_portfolio]

    test "lists all portfolios", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/portfolios")

      assert html =~ "Listing Portfolios"
    end

    test "shows positions for portfolio", %{conn: conn, portfolio: portfolio} do
      {:ok, _index_live, html} = live(conn, ~p"/portfolios/#{portfolio.id}")

      assert html =~ portfolio.broker
      assert html =~ portfolio.description
    end

    test "saves new portfolio", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/portfolios")

      assert index_live |> element("a", "New Portfolio") |> render_click() =~
               "New Portfolio"

      assert_patch(index_live, ~p"/portfolios/new")

      assert index_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#portfolio-form", portfolio: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/portfolios")

      html = render(index_live)
      assert html =~ "Portfolio created successfully"
    end

    test "updates portfolio in listing", %{conn: conn, portfolio: portfolio} do
      {:ok, index_live, _html} = live(conn, ~p"/portfolios")

      assert index_live |> element("#portfolios-#{portfolio.id} a", "Edit") |> render_click() =~
               "Edit Portfolio"

      assert_patch(index_live, ~p"/portfolios/#{portfolio}/edit")

      assert index_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#portfolio-form", portfolio: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/portfolios")

      html = render(index_live)
      assert html =~ "Portfolio updated successfully"
    end

    test "deletes portfolio in listing", %{conn: conn, portfolio: portfolio} do
      {:ok, index_live, _html} = live(conn, ~p"/portfolios")

      assert index_live |> element("#portfolios-#{portfolio.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#portfolios-#{portfolio.id}")
    end
  end
end

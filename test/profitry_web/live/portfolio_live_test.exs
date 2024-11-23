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

  describe "Portfolios" do
    setup [:create_portfolio]

    test "lists all portfolios", %{conn: conn, portfolio: portfolio} do
      {:ok, _portfolio_live, html} = live(conn, ~p"/portfolios")

      assert html =~ "Listing Portfolios"
      assert html =~ portfolio.broker
      assert html =~ portfolio.description
    end

    test "saves new portfolio", %{conn: conn} do
      {:ok, portfolio_live, _html} = live(conn, ~p"/portfolios")

      assert portfolio_live |> element("a", "New Portfolio") |> render_click() =~
               "New Portfolio"

      assert_patch(portfolio_live, ~p"/portfolios/new")

      assert portfolio_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert portfolio_live
             |> form("#portfolio-form", portfolio: @create_attrs)
             |> render_submit()

      assert_patch(portfolio_live, ~p"/portfolios")

      html = render(portfolio_live)
      assert html =~ "Portfolio created successfully"
    end

    test "updates portfolio in listing", %{conn: conn, portfolio: portfolio} do
      {:ok, portfolio_live, _html} = live(conn, ~p"/portfolios")

      assert portfolio_live |> element("#portfolios-#{portfolio.id} a", "Edit") |> render_click() =~
               "Edit Portfolio"

      assert_patch(portfolio_live, ~p"/portfolios/#{portfolio}/edit")

      assert portfolio_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert portfolio_live
             |> form("#portfolio-form", portfolio: @update_attrs)
             |> render_submit()

      assert_patch(portfolio_live, ~p"/portfolios")

      html = render(portfolio_live)
      assert html =~ "Portfolio updated successfully"
    end

    test "deletes portfolio in listing", %{conn: conn, portfolio: portfolio} do
      {:ok, portfolio_live, _html} = live(conn, ~p"/portfolios")

      assert portfolio_live
             |> element("#portfolios-#{portfolio.id} a", "Delete")
             |> render_click()

      refute has_element?(portfolio_live, "#portfolios-#{portfolio.id}")
    end
  end
end

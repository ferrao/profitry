defmodule ProfitryWeb.PortfolioLiveTest do
  use ProfitryWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Profitry.InvestmentFixtures
  import Profitry.AccountsFixtures

  @create_attrs %{broker: "BROKER", description: "desc"}
  @update_attrs %{broker: "BROKER", description: "new desc"}
  @invalid_attrs %{broker: "BROKER", description: ""}

  defp create_portfolio(_) do
    portfolio = portfolio_fixture()
    %{portfolio: portfolio}
  end

  defp login(%{conn: conn}) do
    %{conn: login_user(conn, user_fixture())}
  end

  describe "Portfolios" do
    setup [:create_portfolio, :login]

    test "lists all portfolios", %{conn: conn, portfolio: portfolio} do
      {:ok, _portfolio_live, html} = live(conn, ~p"/portfolios")

      assert html =~ "Listing Portfolios"
      assert html =~ portfolio.broker
      assert html =~ portfolio.description
    end

    test "counts portfolios", %{conn: conn} do
      {:ok, portfolio_live, _html} = live(conn, ~p"/portfolios")

      assert portfolio_live
             |> element("span#count-portfolios")
             |> render() =~ "(1)"
    end

    test "saves new portfolio", %{conn: conn} do
      {:ok, portfolio_live, _html} = live(conn, ~p"/portfolios")

      assert portfolio_live
             |> element("a", "New Portfolio")
             |> render_click() =~ "Save Portfolio"

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

      assert portfolio_live
             |> element("span#count-portfolios")
             |> render() =~ "(2)"
    end

    test "updates existing portfolio", %{conn: conn, portfolio: portfolio} do
      {:ok, portfolio_live, _html} = live(conn, ~p"/portfolios")

      assert portfolio_live
             |> element("#portfolios-#{portfolio.id} a", "Edit")
             |> render_click() =~ "Edit Portfolio"

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

      assert portfolio_live
             |> element("span#count-portfolios")
             |> render() =~ "(1)"
    end

    test "deletes existing portfolio", %{conn: conn, portfolio: portfolio} do
      {:ok, portfolio_live, _html} = live(conn, ~p"/portfolios")

      assert portfolio_live
             |> element("#portfolios-#{portfolio.id} a", "Delete")
             |> render_click()

      refute has_element?(portfolio_live, "#portfolios-#{portfolio.id}")

      assert portfolio_live
             |> element("span#count-portfolios")
             |> render() =~ "(0)"
    end
  end
end

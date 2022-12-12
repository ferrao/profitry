defmodule ProfitryAppWeb.PortfolioLiveTest do
  use ProfitryAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import ProfitryApp.InvestmentFixtures

  @create_attrs %{name: "some name", tikr: "some tikr"}
  @update_attrs %{name: "some updated name", tikr: "some updated tikr"}
  @invalid_attrs %{name: nil, tikr: nil}

  defp create_portfolio(_) do
    portfolio = portfolio_fixture()
    %{portfolio: portfolio}
  end

  describe "Index" do
    setup [:create_portfolio]

    test "lists all portfolios", %{conn: conn, portfolio: portfolio} do
      {:ok, _index_live, html} = live(conn, ~p"/portfolios")

      assert html =~ "Listing Portfolios"
      assert html =~ portfolio.name
    end

    test "saves new portfolio", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/portfolios")

      assert index_live |> element("a", "New Portfolio") |> render_click() =~
               "New Portfolio"

      assert_patch(index_live, ~p"/portfolios/new")

      assert index_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#portfolio-form", portfolio: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/portfolios")

      assert html =~ "Portfolio created successfully"
      assert html =~ "some name"
    end

    test "updates portfolio in listing", %{conn: conn, portfolio: portfolio} do
      {:ok, index_live, _html} = live(conn, ~p"/portfolios")

      assert index_live |> element("#portfolios-#{portfolio.id} a", "Edit") |> render_click() =~
               "Edit Portfolio"

      assert_patch(index_live, ~p"/portfolios/#{portfolio}/edit")

      assert index_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#portfolio-form", portfolio: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/portfolios")

      assert html =~ "Portfolio updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes portfolio in listing", %{conn: conn, portfolio: portfolio} do
      {:ok, index_live, _html} = live(conn, ~p"/portfolios")

      assert index_live |> element("#portfolios-#{portfolio.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#portfolio-#{portfolio.id}")
    end
  end

  describe "Show" do
    setup [:create_portfolio]

    test "displays portfolio", %{conn: conn, portfolio: portfolio} do
      {:ok, _show_live, html} = live(conn, ~p"/portfolios/#{portfolio}")

      assert html =~ "Show Portfolio"
      assert html =~ portfolio.name
    end

    test "updates portfolio within modal", %{conn: conn, portfolio: portfolio} do
      {:ok, show_live, _html} = live(conn, ~p"/portfolios/#{portfolio}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Portfolio"

      assert_patch(show_live, ~p"/portfolios/#{portfolio}/show/edit")

      assert show_live
             |> form("#portfolio-form", portfolio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#portfolio-form", portfolio: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/portfolios/#{portfolio}")

      assert html =~ "Portfolio updated successfully"
      assert html =~ "some updated name"
    end
  end
end

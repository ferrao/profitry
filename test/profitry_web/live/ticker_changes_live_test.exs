defmodule ProfitryWeb.TickerChangesLiveTest do
  use ProfitryWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Profitry.InvestmentFixtures
  import Profitry.AccountsFixtures

  @create_attrs %{ticker: "TSLA", original_ticker: "TSL", date: ~D[2020-01-01]}
  @update_attrs %{ticker: "TSLA", original_ticker: "TLA", date: ~D[2021-01-01]}
  @invalid_attrs %{ticker: "", original_ticker: ""}

  defp create_ticker_change(_) do
    ticker_change = ticker_change_fixture()
    %{ticker_change: ticker_change}
  end

  defp login(%{conn: conn}) do
    %{conn: login_user(conn, user_fixture())}
  end

  describe "Ticker Changes" do
    setup [:create_ticker_change, :login]

    test "lists all ticker changes", %{conn: conn, ticker_change: ticker_change} do
      {:ok, _ticker_change_live, html} = live(conn, ~p"/ticker-changes")

      assert html =~ "Listing Ticker Changes"
      assert html =~ ticker_change.ticker
    end

    test "counts ticker changes", %{conn: conn} do
      {:ok, ticker_change_live, _html} = live(conn, ~p"/ticker-changes")

      assert ticker_change_live
             |> element("span#count-ticker-changes")
             |> render() =~ "(1)"
    end

    test "saves a new ticker change", %{conn: conn} do
      {:ok, ticker_change_live, _html} = live(conn, ~p"/ticker-changes")

      assert ticker_change_live
             |> element("a", "New Ticker Change")
             |> render_click() =~ "New Ticker Change"

      assert_patch(ticker_change_live, ~p"/ticker-changes/new")

      assert ticker_change_live
             |> form("#ticker-change-form", ticker_change: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert ticker_change_live
             |> form("#ticker-change-form", ticker_change: @create_attrs)
             |> render_submit()

      assert_patch(ticker_change_live, ~p"/ticker-changes")

      html = render(ticker_change_live)
      assert html =~ "Ticker Change created successfully"

      assert ticker_change_live
             |> element("span#count-ticker-changes")
             |> render() =~ "(2)"
    end

    test "updates existing ticker change", %{conn: conn, ticker_change: ticker_change} do
      {:ok, ticker_change_live, _html} = live(conn, ~p"/ticker-changes")

      assert ticker_change_live
             |> element("#ticker_changes-#{ticker_change.id} a", "Edit")
             |> render_click() =~ "Edit Ticker Change"

      assert_patch(ticker_change_live, ~p"/ticker-changes/#{ticker_change}/edit")

      assert ticker_change_live
             |> form("#ticker-change-form", ticker_change: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert ticker_change_live
             |> form("#ticker-change-form", ticker_change: @update_attrs)
             |> render_submit()

      assert_patch(ticker_change_live, ~p"/ticker-changes")

      html = render(ticker_change_live)
      assert html =~ "Ticker Change updated successfully"

      assert ticker_change_live
             |> element("span#count-ticker-changes")
             |> render() =~ "(1)"
    end

    test "deletes existing ticker change", %{conn: conn, ticker_change: ticker_change} do
      {:ok, ticker_change_live, _html} = live(conn, ~p"/ticker-changes")

      assert ticker_change_live
             |> element("#ticker_changes-#{ticker_change.id} a", "Delete")
             |> render_click()

      refute has_element?(ticker_change_live, "#ticker-changes-#{ticker_change.id}")

      assert ticker_change_live
             |> element("span#count-ticker-changes")
             |> render() =~ "(0)"
    end
  end
end

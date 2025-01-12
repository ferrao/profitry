defmodule ProfitryWeb.SplitLiveTest do
  use ProfitryWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Profitry.InvestmentFixtures
  import Profitry.AccountsFixtures

  @create_attrs %{ticker: "TSLA", multiple: 3, reverse: false, date: ~D[2020-01-01]}
  @update_attrs %{ticker: "TSLA", multiple: 2, reverse: true}
  @invalid_attrs %{multiple: 0}

  defp create_split(_) do
    split = split_fixture()
    %{split: split}
  end

  defp login(%{conn: conn}) do
    %{conn: login_user(conn, user_fixture())}
  end

  describe "Stock Splits" do
    setup [:create_split, :login]

    test "lists all stock splits", %{conn: conn, split: split} do
      {:ok, _split_live, html} = live(conn, ~p"/splits")

      assert html =~ "Listing Stock Splits"
      assert html =~ split.ticker
    end

    test "counts splits", %{conn: conn} do
      {:ok, split_live, _html} = live(conn, ~p"/splits")

      assert split_live
             |> element("span#count-splits")
             |> render() =~ "(1)"
    end

    test "saves a new stock split", %{conn: conn} do
      {:ok, split_live, _html} = live(conn, ~p"/splits")

      assert split_live
             |> element("a", "New Stock Split")
             |> render_click() =~ "New Stock Split"

      assert_patch(split_live, ~p"/splits/new")

      assert split_live
             |> form("#split-form", split: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert split_live
             |> form("#split-form", split: @create_attrs)
             |> render_submit()

      assert_patch(split_live, ~p"/splits")

      html = render(split_live)
      assert html =~ "Stock Split created successfully"

      assert split_live
             |> element("span#count-splits")
             |> render() =~ "(2)"
    end

    test "updates existing stock split", %{conn: conn, split: split} do
      {:ok, split_live, _html} = live(conn, ~p"/splits")

      assert split_live
             |> element("#splits-#{split.id} a", "Edit")
             |> render_click() =~ "Edit Stock Split"

      assert_patch(split_live, ~p"/splits/#{split}/edit")

      assert split_live
             |> form("#split-form", split: @invalid_attrs)
             |> render_change() =~ "must be greater than 0"

      assert split_live
             |> form("#split-form", split: @update_attrs)
             |> render_submit()

      assert_patch(split_live, ~p"/splits")

      html = render(split_live)
      assert html =~ "Stock Split updated successfully"

      assert split_live
             |> element("span#count-splits")
             |> render() =~ "(1)"
    end

    test "deletes existing stock split", %{conn: conn, split: split} do
      {:ok, split_live, _html} = live(conn, ~p"/splits")

      assert split_live
             |> element("#splits-#{split.id} a", "Delete")
             |> render_click()

      refute has_element?(split_live, "#splits-#{split.id}")

      assert split_live
             |> element("span#count-splits")
             |> render() =~ "(0)"
    end
  end
end

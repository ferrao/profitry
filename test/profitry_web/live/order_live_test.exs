defmodule ProfitryWeb.OrderLiveTest do
  use ProfitryWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Profitry.InvestmentFixtures
  import Profitry.AccountsFixtures

  @create_attrs %{
    type: :buy,
    instrument: :stock,
    quantity: "2",
    price: "0.75",
    fees: "0.5",
    inserted_at: "2024-11-30T14:10"
  }
  @update_attrs %{type: :sell, instrument: :option, price: "0.8"}
  @invalid_attrs %{price: ""}

  @create_attrs_option %{
    type: :buy,
    instrument: :option,
    quantity: "2",
    price: "0.75",
    fees: "1.5",
    inserted_at: "2024-11-30T14:10",
    option: %{
      type: "call",
      strike: "110",
      expiration: "2024-12-12"
    }
  }

  @update_attrs_option %{type: :sell, option: %{type: "put", strike: "100"}}
  @invalid_attrs_option %{@create_attrs_option | option: %{strike: ""}}

  defp create_order(_) do
    {portfolio, position, order} = order_fixture()
    order_option = option_fixture(position)
    %{portfolio: portfolio, position: position, order: order, order_option: order_option}
  end

  defp login(%{conn: conn}) do
    %{conn: login_user(conn, user_fixture())}
  end

  describe "Orders" do
    setup [:create_order, :login]

    test "lists all orders for a position", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order: order,
      order_option: order_option
    } do
      {:ok, _order_live, html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert html =~ "Listing Orders"
      assert html =~ position.ticker
      assert html =~ to_string(order.type)
      assert html =~ to_string(order_option.type)
      assert html =~ to_string(order_option.instrument)
      assert html =~ Decimal.to_string(order_option.quantity)
      assert html =~ Decimal.to_string(order_option.price)
    end

    test "displays split for position splits", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order: order
    } do
      split_fixture()

      {:ok, _order_live, html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      [before_order | _] = String.split(html, to_string(order.type))
      assert String.contains?(before_order, "1:3 Split")
    end

    test "counts orders", %{
      conn: conn,
      portfolio: portfolio,
      position: position
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(2 orders)"
    end

    test "opens option contract details", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order_option: order
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert order_live
             |> element("#orders-#{order.id} a.option-contract")
             |> render_click()

      assert has_element?(order_live, "div#option-modal-content")
    end

    test "saves new order without options contracts", %{
      conn: conn,
      portfolio: portfolio,
      position: position
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert order_live
             |> element("a", "New Order")
             |> render_click() =~ "Add Order"

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders/new"
      )

      assert order_live
             |> form("#order-form", order: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert order_live
             |> form("#order-form", order: @create_attrs)
             |> render_submit()

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders"
      )

      html = render(order_live)
      assert html =~ "Order created successfully"

      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(3 orders)"
    end

    test "saves new order with an options contract", %{
      conn: conn,
      portfolio: portfolio,
      position: position
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert order_live
             |> element("a", "New Order")
             |> render_click() =~ "Add Order"

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders/new"
      )

      html =
        order_live
        |> element("#order-form")
        |> render_change(%{order: %{instrument: "option"}})

      assert html =~ "Contract"
      assert html =~ "Strike"
      assert html =~ "Expiration Date"

      assert order_live
             |> form("#order-form", order: @invalid_attrs_option)
             |> render_change() =~ "can&#39;t be blank"

      assert order_live
             |> form("#order-form", order: @create_attrs_option)
             |> render_submit()

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders"
      )

      html = render(order_live)
      assert html =~ "Order created successfully"

      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(3 orders)"
    end

    test "updates existing order without options contracts", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order: order
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert order_live
             |> element("#orders-#{order.id} a", "Edit")
             |> render_click() =~ "Edit Order"

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders/#{order.id}/edit"
      )

      assert order_live
             |> form("#order-form", order: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert order_live
             |> form("#order-form", order: @update_attrs)
             |> render_submit()

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders"
      )

      html = render(order_live)
      assert html =~ "Order updated successfully"

      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(2 orders)"
    end

    test "updates existing order with an options contract", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order_option: order
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert order_live
             |> element("#orders-#{order.id} a", "Edit")
             |> render_click() =~ "Edit Order"

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders/#{order.id}/edit"
      )

      assert order_live
             |> form("#order-form", order: @invalid_attrs_option)
             |> render_change() =~ "can&#39;t be blank"

      assert order_live
             |> form("#order-form", order: @update_attrs_option)
             |> render_submit()

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders"
      )

      html = render(order_live)
      assert html =~ "Order updated successfully"

      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(2 orders)"
    end

    test "deletes an existing order without options contracts", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order: order
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert order_live
             |> element("#orders-#{order.id} a", "Delete")
             |> render_click()

      refute has_element?(order_live, "#order-#{order.id}")

      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(1 orders)"
    end

    test "deletes an existing order with options contract", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order_option: order
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert order_live
             |> element("#orders-#{order.id} a", "Delete")
             |> render_click()

      refute has_element?(order_live, "#order-#{order.id}")

      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(1 orders)"
    end
  end
end

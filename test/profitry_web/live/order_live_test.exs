defmodule ProfitryWeb.OrderLiveTest do
  use ProfitryWeb.ConnCase

  import Phoenix.LiveViewTest
  import Profitry.InvestmentFixtures

  @create_attrs %{
    type: :buy,
    instrument: :stock,
    quantity: "2",
    price: "0.75",
    inserted_at: "2024-11-30T14:10"
  }
  @update_attrs %{type: :sell, instrument: :option, price: "0.8"}
  @invalid_attrs %{price: ""}

  defp create_order(_) do
    {portfolio, position, order} = order_fixture()
    %{portfolio: portfolio, position: position, order: order}
  end

  describe "Orders" do
    setup [:create_order]

    test "lists all orders for a position", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order: order
    } do
      {:ok, _order_live, html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.ticker}/orders")

      assert html =~ "Listing Orders"
      assert html =~ position.ticker
      assert html =~ to_string(order.type)
      assert html =~ to_string(order.instrument)
      assert html =~ Decimal.to_string(order.quantity)
      assert html =~ Decimal.to_string(order.price)
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
             |> render() =~ "(1 orders)"
    end

    test "saves new order", %{
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
             |> render() =~ "(2 orders)"
    end

    test "updates existing order", %{
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
             |> render() =~ "(1 orders)"
    end

    test "deletes an existing order", %{
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
             |> render() =~ "(0 orders)"
    end
  end
end

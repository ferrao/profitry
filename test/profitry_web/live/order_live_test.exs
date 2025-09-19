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
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

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
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

      [before_order | _] = String.split(html, to_string(order.type))
      assert String.contains?(before_order, "1:3 Split")
    end

    test "counts orders", %{
      conn: conn,
      portfolio: portfolio,
      position: position
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

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
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

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
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

      assert order_live
             |> element("a", "New Order")
             |> render_click() =~ "Add Order"

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders/new"
      )

      assert order_live
             |> form("#order-form", order: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert order_live
             |> form("#order-form", order: @create_attrs)
             |> render_submit()

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders"
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
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

      assert order_live
             |> element("a", "New Order")
             |> render_click() =~ "Add Order"

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders/new"
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
        ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders"
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
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

      assert order_live
             |> element("#orders-#{order.id} a", "Edit")
             |> render_click() =~ "Edit Order"

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders/#{order.id}/edit"
      )

      assert order_live
             |> form("#order-form", order: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert order_live
             |> form("#order-form", order: @update_attrs)
             |> render_submit()

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders"
      )

      html = render(order_live)
      assert html =~ "Order updated successfully"

      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(2 orders)"
    end

    test "preserves index field when editing order", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order: order
    } do
      # Create a split to ensure the orders table checks for index field
      split_fixture()

      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

      # Verify initial render works (this would fail if index field was missing)
      html = render(order_live)
      assert html =~ "1:3 Split"
      assert html =~ to_string(order.type)

      # Edit the order
      assert order_live
             |> element("#orders-#{order.id} a", "Edit")
             |> render_click() =~ "Edit Order"

      # Update the order without changing the date
      update_attrs_no_date = %{type: :sell, price: "1.50"}

      assert order_live
             |> form("#order-form", order: update_attrs_no_date)
             |> render_submit()

      # Verify the page still renders correctly after the update
      # This would fail with a KeyError if the index field was missing
      html = render(order_live)
      assert html =~ "Order updated successfully"
      # Split display depends on index field
      assert html =~ "1:3 Split"
    end

    test "resets stream when order index changes due to date modification", %{
      conn: conn,
      portfolio: portfolio,
      position: position
    } do
      # Create orders with different dates to establish a clear ordering
      earlier_order = order_fixture(position, %{inserted_at: ~N[2023-01-01 12:00:00]})
      later_order = order_fixture(position, %{inserted_at: ~N[2023-03-01 12:00:00]})

      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

      # Verify initial state - all orders are visible
      html = render(order_live)
      assert html =~ to_string(earlier_order.type)
      assert html =~ to_string(later_order.type)

      # Now edit the later order to have an earlier date, which should change its index
      new_earlier_date = "2022-12-01T12:00"

      assert order_live
             |> element("#orders-#{later_order.id} a", "Edit")
             |> render_click() =~ "Edit Order"

      # Update with an earlier date that should change its sorting position
      update_with_new_date = %{inserted_at: new_earlier_date}

      assert order_live
             |> form("#order-form", order: update_with_new_date)
             |> render_submit()

      # Verify the update succeeded and all orders are still visible
      html = render(order_live)
      assert html =~ "Order updated successfully"

      # All orders should still be visible (no index collision errors)
      assert html =~ to_string(earlier_order.type)
      assert html =~ to_string(later_order.type)

      # Verify the count is still correct (no orders lost due to stream issues)
      assert order_live
             |> element("span#count-orders")
             |> render() =~ "(4 orders)"
    end

    test "updates existing order with an options contract", %{
      conn: conn,
      portfolio: portfolio,
      position: position,
      order_option: order
    } do
      {:ok, order_live, _html} =
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

      assert order_live
             |> element("#orders-#{order.id} a", "Edit")
             |> render_click() =~ "Edit Order"

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders/#{order.id}/edit"
      )

      assert order_live
             |> form("#order-form", order: @invalid_attrs_option)
             |> render_change() =~ "can&#39;t be blank"

      assert order_live
             |> form("#order-form", order: @update_attrs_option)
             |> render_submit()

      assert_patch(
        order_live,
        ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders"
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
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

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
        live(conn, ~p"/portfolios/#{portfolio.id}/positions/#{position.id}/orders")

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

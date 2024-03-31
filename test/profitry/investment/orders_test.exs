defmodule Profitry.Investment.OrdersTest do
  use Profitry.DataCase, async: true

  import Profitry.InvestmentFixtures

  alias Profitry.Investment
  # alias Profitry.Investment.Orders
  # alias Profitry.Investment.Schema.Order

  describe "order" do
    test "list_orders/1 returns the orders for a position" do
      {_portfolio, position, order} = order_fixture()

      assert Investment.list_orders(position)
             |> Repo.preload(position: :portfolio) == [order]
    end
  end
end

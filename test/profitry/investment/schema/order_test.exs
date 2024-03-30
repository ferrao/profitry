defmodule Profitry.Investment.Schema.OrderTest do
  use Profitry.DataCase, async: true

  alias Profitry.Investment.Schema.Order

  describe "order" do
    test "type is required" do
      changeset = Order.changeset(%Order{}, %{})
      assert ["can't be blank"] = errors_on(changeset).type
    end

    test "instrument is required" do
      changeset = Order.changeset(%Order{}, %{})
      assert ["can't be blank"] = errors_on(changeset).instrument
    end

    test "quantity is required" do
      changeset = Order.changeset(%Order{}, %{})
      assert ["can't be blank"] = errors_on(changeset).quantity
    end

    test "price is required" do
      changeset = Order.changeset(%Order{}, %{})
      assert ["can't be blank"] = errors_on(changeset).price
    end

    test "inserted time is required" do
      changeset = Order.changeset(%Order{}, %{})
      assert ["can't be blank"] = errors_on(changeset).inserted_at
    end

    test "quantity needs to be greater than zero" do
      error = "must be greater than 0"

      changeset1 = Order.changeset(%Order{}, %{quantity: "0"})
      changeset2 = Order.changeset(%Order{}, %{quantity: "-1.4"})
      changeset3 = Order.changeset(%Order{}, %{quantity: "1.3"})
      assert [^error] = errors_on(changeset1).quantity
      assert [^error] = errors_on(changeset2).quantity
      refute Map.has_key?(errors_on(changeset3), :quantity)
    end

    test "price needs to be greater than or equal to zero" do
      error = "must be greater than or equal to 0"

      changeset1 = Order.changeset(%Order{}, %{price: "-1.2"})
      changeset2 = Order.changeset(%Order{}, %{price: "0"})
      changeset3 = Order.changeset(%Order{}, %{price: "1.3"})

      assert [^error] = errors_on(changeset1).price
      refute Map.has_key?(errors_on(changeset2), :price)
      refute Map.has_key?(errors_on(changeset3), :price)
    end
  end
end

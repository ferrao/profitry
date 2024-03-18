defmodule Profitry.InvestmentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Profitry.Investment` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{

      })
      |> Profitry.Investment.create_order()

    order
  end
end

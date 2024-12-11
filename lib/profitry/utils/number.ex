defmodule Profitry.Utils.Number do
  @moduledoc """

  Utilities for working with numbers

  """

  alias Number.Currency

  @doc """

    Formats a number for using in web views

  """
  @spec format_number(Decimal.t()) :: String.t()
  def format_number(number) do
    number
    |> Decimal.round(2)
    |> Decimal.normalize()
    |> Decimal.to_string(:normal)
  end

  @doc """

    Formats a number as currency for using in web views

  """
  @spec format_number(Decimal.t()) :: String.t()
  def format_currency(number) do
    number
    |> Currency.number_to_currency()
  end
end

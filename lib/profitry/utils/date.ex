defmodule Profitry.Utils.Date do
  @moduledoc """

  Date related utilities

  """

  @doc """

  Parses an option expiration date string into a Date struct

  ## Examples

    iex> parse_expiration("17DEC21")
    {:ok, ~D[2021-12-17]}

    iex> parse_expiration("xpto")
    ** (RuntimeError) Expected `day of month` at line 1, column 1.

  """
  @spec parse_expiration!(String.t()) :: Date.t() | no_return()
  def parse_expiration!(date_str) when is_binary(date_str) and byte_size(date_str) == 7 do
    day = date_str |> String.slice(0, 2)
    month = date_str |> String.slice(2, 3) |> String.downcase() |> String.capitalize()
    year = date_str |> String.slice(5, 2)

    # parse date using C strftime format
    case Timex.parse("#{day}#{month}#{year}", "%d%b%y", :strftime) do
      {:ok, datetime} -> Timex.to_date(datetime)
      {:error, reason} -> raise reason
    end
  end

  @doc """

  Timestamps as properly formatted strings

  ## Examples

    iex> date(~N[2019-10-31 23:00:07])
    "31/10/2019 23:00:07"

  """
  @spec format_timestamp(NaiveDateTime.t()) :: String.t()
  def format_timestamp(date), do: Calendar.strftime(date, "%d/%m/%Y %H:%M:%S")
end

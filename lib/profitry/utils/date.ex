defmodule Profitry.Utils.Date do
  @moduledoc """

  Date related utilities

  """

  @doc """

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
end

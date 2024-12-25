defmodule Profitry.Utils.UnixTime do
  @moduledoc """

  Ecto custom type for representing Unix timestamp

  """

  use Ecto.Type

  @impl true
  def type, do: :datetime

  @impl true
  def cast(timestamp) when is_integer(timestamp), do: DateTime.from_unix(timestamp)
  def cast(_), do: :error

  @impl true
  def dump(value), do: Ecto.Type.dump(:naive_datetime, value)

  @impl true
  def load(value), do: Ecto.Type.load(:naive_datetime, value)
end

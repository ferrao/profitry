defmodule ProfitryApp.Utils.UnixTime do
  use Ecto.Type
  def type, do: :datetime

  def cast(timestamp) when is_integer(timestamp), do: DateTime.from_unix(timestamp)
  def cast(_), do: :error

  def dump(value), do: Ecto.Type.dump(:datetime, value)
  def load(value), do: Ecto.Type.load(:datetime, value)
end

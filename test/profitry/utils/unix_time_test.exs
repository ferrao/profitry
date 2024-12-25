defmodule Profitry.Utils.UnixTimeTest do
  use ExUnit.Case, async: true

  alias Profitry.Utils.UnixTime

  describe "unix timestamp ecto type" do
    test "type/0 returns :datetime" do
      assert UnixTime.type() == :datetime
    end

    test "cast/1 casts valid unix timestamp" do
      # March 1, 2023 00:00:00 UTC
      timestamp = 1_677_676_800

      assert UnixTime.cast(timestamp) === DateTime.from_unix(timestamp)
    end

    test "cast/1 returns error for non valid unix timestamps" do
      assert :error = UnixTime.cast("not an integer")
      assert :error = UnixTime.cast(3.14)
      assert :error = UnixTime.cast(nil)
      assert :error = UnixTime.cast(%{})
    end

    test "dump/1 delegates to Ecto.Type.dump" do
      datetime = DateTime.utc_now()
      assert UnixTime.dump(datetime) == Ecto.Type.dump(:naive_datetime, datetime)
    end

    test "load/1 delegates to Ecto.Type.load" do
      naive_datetime = ~N[2023-03-01 00:00:00]
      assert UnixTime.load(naive_datetime) == Ecto.Type.load(:naive_datetime, naive_datetime)
    end
  end
end

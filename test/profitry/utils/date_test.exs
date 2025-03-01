defmodule Profitry.Utils.DateTest do
  use ExUnit.Case, async: true

  import Profitry.Utils.Date

  describe "date utils" do
    test "parse option expiration date" do
      assert ~D[2021-12-17] = parse_expiration!("17DEC21")
    end

    test "parse invalid data returns error" do
      assert_raise RuntimeError, ~r/^Expected/, fn -> parse_expiration!("32DEC21") end
    end

    test "renders date" do
      assert format_timestamp(~N[2019-10-31 23:00:07]) === "31/10/2019 23:00:07"
    end

    test "after_today?/1 checks if date is in future" do
      assert false === after_today?(Date.utc_today())
      assert false === after_today?(Date.add(Date.utc_today(), -1))
      assert true === after_today?(Date.add(Date.utc_today(), +1))
    end

    test "before_today?/1 checks if date is in past" do
      assert false === before_today?(Date.utc_today())
      assert false === before_today?(Date.add(Date.utc_today(), +1))
      assert true === before_today?(Date.add(Date.utc_today(), -1))
    end
  end
end

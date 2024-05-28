defmodule Profitry.Utils.DateTest do
  use ExUnit.Case, async: true

  alias Profitry.Utils.Date

  describe "date utils" do
    test "parse option expiration date" do
      assert ~D[2021-12-17] = Date.parse_expiration!("17DEC21")
    end

    test "parse invalid data returns error" do
      assert_raise RuntimeError, ~r/^Expected/, fn -> Date.parse_expiration!("32DEC21") end
    end
  end
end

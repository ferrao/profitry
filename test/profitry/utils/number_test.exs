defmodule Profitry.Utils.NumberTest do
  use ExUnit.Case, async: true

  import Profitry.Utils.Number

  describe "number utils" do
    test "format number" do
      assert format_number(Decimal.new("1.83333")) == "1.83"
      assert format_number(Decimal.new("10")) == "10"
    end

    test "format currency" do
      assert format_currency(Decimal.new("1.83333")) == "$1.83"
      assert format_currency(Decimal.new("10")) == "$10.00"
    end
  end
end

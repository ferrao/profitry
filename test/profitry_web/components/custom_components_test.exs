defmodule ProfitryWeb.CustomComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import ProfitryWeb.CustomComponents

  describe "profit component" do
    test "renders profit with no totals" do
      assert render_component(&profit/1, profit: Decimal.new("12.2")) =~ "text-green"
      assert render_component(&profit/1, profit: Decimal.new("12.2")) =~ "$12.20"
      assert render_component(&profit/1, profit: Decimal.new("0.2")) =~ "text-green"
      assert render_component(&profit/1, profit: Decimal.new("0.2")) =~ "$0.20"
      assert render_component(&profit/1, profit: Decimal.new("-12.2")) =~ "text-red"
      assert render_component(&profit/1, profit: Decimal.new("-12.2")) =~ "-$12.20"
      assert render_component(&profit/1, profit: Decimal.new("-0.2")) =~ "text-red"
      assert render_component(&profit/1, profit: Decimal.new("-0.2")) =~ "-$0.20"
    end

    test "renders profit with totals" do
      assert render_component(&profit/1, profit: Decimal.new("12.2"), total: Decimal.new("50.2")) =~
               "text-green"

      assert render_component(&profit/1, profit: Decimal.new("12.2"), total: Decimal.new("50.2")) =~
               "$12.20"

      assert render_component(&profit/1, profit: Decimal.new("-0.4"), total: Decimal.new("50.2")) =~
               "text-yellow"

      assert render_component(&profit/1, profit: Decimal.new("-0.4"), total: Decimal.new("50.2")) =~
               "-$0.40"

      assert render_component(&profit/1, profit: Decimal.new("-12.2"), total: Decimal.new("50.2")) =~
               "text-red"

      assert render_component(&profit/1, profit: Decimal.new("-12.2"), total: Decimal.new("50.2")) =~
               "-$12.20"
    end

    test "renders an option contract icon" do
      assert render_component(&option_icon/1, option: nil) =~ "text-slate-300"

      assert render_component(&option_icon/1, option: %{expiration: Date.utc_today()}) =~
               "text-emerald-600"

      assert render_component(&option_icon/1,
               option: %{expiration: Date.add(Date.utc_today(), 1)}
             ) =~ "text-emerald-600"

      assert render_component(&option_icon/1,
               option: %{expiration: Date.add(Date.utc_today(), -1)}
             ) =~ "text-red-600"
    end

    test "render a position icon" do
      report = %{ticker: "TSLA", shares: 0, long_options: [], short_options: []}

      assert render_component(&position_icon/1, report: report) =~ "TSLA"
      assert render_component(&position_icon/1, report: report) =~ "text-red-700"

      assert render_component(&position_icon/1, report: %{report | shares: 1}) =~ "TSLA"
      assert render_component(&position_icon/1, report: %{report | shares: 1}) =~ "text-green-700"
    end

    test "renders option data" do
      order = %{
        type: :buy,
        quantity: Decimal.new("1.3"),
        price: Decimal.new("132.3"),
        option: %{type: :call, strike: 50, expiration: ~D[2024-02-01]}
      }

      assert render_component(&option_data/1, %{order: order, ticker: "TSLA"}) =~ "TSLA"
      assert render_component(&option_data/1, %{order: order, ticker: "TSLA"}) =~ "Buy"
      assert render_component(&option_data/1, %{order: order, ticker: "TSLA"}) =~ "Call"
      assert render_component(&option_data/1, %{order: order, ticker: "TSLA"}) =~ "$50.00"
      assert render_component(&option_data/1, %{order: order, ticker: "TSLA"}) =~ "$132.30"
      assert render_component(&option_data/1, %{order: order, ticker: "TSLA"}) =~ "2024-02-01"
    end
  end
end

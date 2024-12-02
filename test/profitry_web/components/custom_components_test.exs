defmodule ProfitryWeb.CustomComponentsTest do
  use ExUnit.Case

  import Phoenix.LiveViewTest
  import ProfitryWeb.CustomComponents

  describe "profit component" do
    test "renders profit with no totals" do
      assert render_component(&profit/1, profit: "12.2") =~ "text-green"
      assert render_component(&profit/1, profit: "12.2") =~ "$12.20"
      assert render_component(&profit/1, profit: "0.2") =~ "text-green"
      assert render_component(&profit/1, profit: "0.2") =~ "$0.20"
      assert render_component(&profit/1, profit: "-12.2") =~ "text-red"
      assert render_component(&profit/1, profit: "-12.2") =~ "-$12.20"
      assert render_component(&profit/1, profit: "-0.2") =~ "text-red"
      assert render_component(&profit/1, profit: "-0.2") =~ "-$0.20"
    end

    test "renders profit with totals" do
      assert render_component(&profit/1, profit: "12.2", total: "50.2") =~ "text-green"
      assert render_component(&profit/1, profit: "12.2", total: "50.2") =~ "$12.20"
      assert render_component(&profit/1, profit: "-0.4", total: "50.2") =~ "text-yellow"
      assert render_component(&profit/1, profit: "-0.4", total: "50.2") =~ "-$0.40"
      assert render_component(&profit/1, profit: "-12.2", total: "50.2") =~ "text-red"
      assert render_component(&profit/1, profit: "-12.2", total: "50.2") =~ "-$12.20"
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
             ) =~ "text-red-300"
    end
  end
end

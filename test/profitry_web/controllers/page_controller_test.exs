defmodule ProfitryWeb.PageControllerTest do
  use ProfitryWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Profitry"
    assert html_response(conn, 200) =~ "investment portfolio cost basis calculator"
  end
end

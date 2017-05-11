defmodule LolcMonitorWeb.PageControllerTest do
  use LolcMonitorWeb.ConnCase

  test "GET / contains app.js", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<script src=\"/js/app.js\"></script>"
  end

  test "GET /api/dashboard returns a JSON response", %{conn: conn} do
    conn = get conn, "/api/dashboard"
    assert json_response(conn, 200)
  end
end

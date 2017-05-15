defmodule PipeDream.Web.ElmControllerTest do
  use PipeDream.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "PipeDream"
  end
end

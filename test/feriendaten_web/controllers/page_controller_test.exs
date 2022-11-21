defmodule FeriendatenWeb.PageControllerTest do
  use FeriendatenWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Bundesländer"
  end
end

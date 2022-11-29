defmodule FeriendatenWeb.PageControllerTest do
  use FeriendatenWeb.ConnCase

  alias Feriendaten.Maps

  test "GET /", %{conn: conn} do
    {:ok, land} =
      Maps.create_level(%{
        name: "Land",
        order: 1
      })

    {:ok, bundesland} =
      Maps.create_level(%{
        name: "Bundesland",
        order: 2
      })

    {:ok, deutschland} =
      Maps.create_location(%{
        name: "Deutschland",
        code: "DE",
        level_id: land.id,
        is_active: true
      })

    {:ok, _bayern} =
      Maps.create_location(%{
        name: "Bayern",
        code: "BY",
        level_id: bundesland.id,
        parent_id: deutschland.id,
        is_active: true
      })

    {:ok, _hessen} =
      Maps.create_location(%{
        name: "Hessen",
        code: "HE",
        level_id: bundesland.id,
        parent_id: deutschland.id,
        is_active: true
      })

    {:ok, _false_federal_state} =
      Maps.create_location(%{
        name: "Not active Example Federal State",
        level_id: bundesland.id,
        parent_id: deutschland.id,
        is_active: false
      })

    today = Date.utc_today()
    year = today.year
    next_year = year + 1

    school_year =
      "#{String.slice(Integer.to_string(year), 2..3) <> "/" <> String.slice(Integer.to_string(year + 1), 2..3)}"

    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Schulferientermine Deutschland"
    assert html_response(conn, 200) =~ "Bayern"
    assert html_response(conn, 200) =~ "Hessen"
    refute html_response(conn, 200) =~ "Not active Example Federal State"
    assert html_response(conn, 200) =~ "#{year}"
    assert html_response(conn, 200) =~ "#{next_year}"
    assert html_response(conn, 200) =~ "#{school_year}"
  end
end

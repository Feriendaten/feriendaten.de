defmodule FeriendatenWeb.VacationSlugControllerTest do
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

    {:ok, hessen} =
      Maps.create_location(%{
        name: "Hessen",
        code: "HE",
        level_id: bundesland.id,
        parent_id: deutschland.id,
        is_active: true
      })

    {:ok, bayern} =
      Maps.create_location(%{
        name: "Bayern",
        code: "BY",
        level_id: bundesland.id,
        parent_id: deutschland.id,
        is_active: true
      })

    {:ok, sommerferien} =
      Feriendaten.Calendars.create_vacation(%{
        name: "Sommer",
        colloquial: "Sommerferien",
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    {:ok, _entry} =
      Feriendaten.Calendars.create_entry(%{
        starts_on: ~D[2029-07-10],
        ends_on: ~D[2029-08-10],
        vacation_id: sommerferien.id,
        location_id: hessen.id,
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    {:ok, _entry} =
      Feriendaten.Calendars.create_entry(%{
        starts_on: ~D[2029-07-01],
        ends_on: ~D[2029-08-08],
        vacation_id: sommerferien.id,
        location_id: bayern.id,
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    {:ok, _entry} =
      Feriendaten.Calendars.create_entry(%{
        starts_on: ~D[2030-07-01],
        ends_on: ~D[2030-08-01],
        vacation_id: sommerferien.id,
        location_id: hessen.id,
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    {:ok, _entry} =
      Feriendaten.Calendars.create_entry(%{
        starts_on: ~D[2031-07-02],
        ends_on: ~D[2031-08-15],
        vacation_id: sommerferien.id,
        location_id: hessen.id,
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    conn = get(conn, ~p"/sommerferien/hessen")
    assert html_response(conn, 200) =~ "Sommerferien Hessen"
    assert html_response(conn, 200) =~ "Sommerferien 2029"
    assert html_response(conn, 200) =~ "10.07. - 10.08."
    assert html_response(conn, 200) =~ "32 Tage"
    assert html_response(conn, 200) =~ "Sommerferien 2030"
    assert html_response(conn, 200) =~ "02.07. - 15.08."
    assert html_response(conn, 200) =~ "Sommerferien 2031"

    conn = get(conn, ~p"/sommerferien/hessen?datum=2030-01-01")
    assert html_response(conn, 200) =~ "Sommerferien Hessen"
    refute html_response(conn, 200) =~ "Sommerferien 2029"
    assert html_response(conn, 200) =~ "Sommerferien 2030"
    assert html_response(conn, 200) =~ "Sommerferien 2031"

    conn = get(conn, ~p"/sommerferien/hessen/2029")
    assert html_response(conn, 200) =~ "Sommerferien Hessen 2029"
    assert html_response(conn, 200) =~ "Sommer&shy;ferien 2029"
    assert html_response(conn, 200) =~ "10.07. - 10.08."
    assert html_response(conn, 200) =~ "32 Tage"
    refute html_response(conn, 200) =~ "Sommer&shy;ferien 2030"
    refute html_response(conn, 200) =~ "02.07. - 15.08."
    refute html_response(conn, 200) =~ "Sommer&shy;ferien 2031"

    conn = get(conn, ~p"/sommerferien/hessen/2030")
    assert html_response(conn, 200) =~ "Sommerferien Hessen 2030"
    refute html_response(conn, 200) =~ "Sommer&shy;ferien 2029"
    refute html_response(conn, 200) =~ "10.07. - 10.08."
    assert html_response(conn, 200) =~ "Sommer&shy;ferien 2030"
    assert html_response(conn, 200) =~ "01.07. - 01.08."
    refute html_response(conn, 200) =~ "Sommer&shy;ferien 2031"

    conn = get(conn, ~p"/sommerferien")
    assert html_response(conn, 200) =~ "Sommer&shy;ferien Hes&shy;sen 2029"
    assert html_response(conn, 200) =~ "Sommer&shy;ferien Bay&shy;ern 2029"
    assert html_response(conn, 200) =~ "01.07. - 08.08."
    assert html_response(conn, 200) =~ "Sommer&shy;ferien Hes&shy;sen 2030"
    assert html_response(conn, 200) =~ "10.07. - 10.08."
  end
end

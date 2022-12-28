defmodule FeriendatenWeb.VacationSlugYearControllerTest do
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

    {:ok, herbstferien} =
      Feriendaten.Calendars.create_vacation(%{
        name: "Herbst",
        colloquial: "Herbstferien",
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

    {:ok, _entry} =
      Feriendaten.Calendars.create_entry(%{
        starts_on: ~D[2030-10-01],
        ends_on: ~D[2030-10-06],
        vacation_id: herbstferien.id,
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
        starts_on: ~D[2030-10-01],
        ends_on: ~D[2030-10-12],
        vacation_id: herbstferien.id,
        location_id: bayern.id,
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    conn = get(conn, ~p"/sommerferien/hessen/2029")
    assert html_response(conn, 200) =~ "Sommerferien Hessen 2029"
    assert html_response(conn, 200) =~ "10.07. - 10.08."
    assert html_response(conn, 200) =~ "32 Tage"
    refute html_response(conn, 200) =~ "02.07. - 15.08."

    assert html_response(conn, 200) =~ ~S"""
           <meta name="description" content="Termine und weitere Informationen zu den Sommerferien Hessen 2029: 10.07. - 10.08.">
           """

    assert html_response(conn, 200) =~ ~S"""
           <meta name="twitter:title" content="Sommerferien Hessen 2029">
           """

    assert html_response(conn, 200) =~ ~S"""
           <meta property="og:title" content="Sommerferien Hessen 2029">
           """

    conn = get(conn, ~p"/sommerferien/hessen/2030")
    assert html_response(conn, 200) =~ "Sommerferien Hessen 2030"
    assert html_response(conn, 200) =~ "01.07. - 01.08."
    refute html_response(conn, 200) =~ "10.07. - 10.08."

    conn = get(conn, ~p"/herbstferien/hessen/2030")
    assert html_response(conn, 200) =~ "Warum sind die Herbstferien Hessen 2030 so kurz?"

    conn = get(conn, ~p"/herbstferien/bayern/2030")
    refute html_response(conn, 200) =~ "Warum sind die Herbstferien Bayern 2030 so kurz?"
  end
end

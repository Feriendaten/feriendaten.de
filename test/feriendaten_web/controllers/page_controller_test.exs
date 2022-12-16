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

    {:ok, weihnachtsferien} =
      Feriendaten.Calendars.create_vacation(%{
        name: "Weihnachten",
        colloquial: "Weihnachtsferien",
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    {:ok, _entry} =
      Feriendaten.Calendars.create_entry(%{
        starts_on: ~D[2030-07-10],
        ends_on: ~D[2030-08-10],
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
        starts_on: ~D[2030-07-01],
        ends_on: ~D[2030-08-08],
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
        starts_on: ~D[2031-07-10],
        ends_on: ~D[2031-08-10],
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
        starts_on: ~D[2031-07-01],
        ends_on: ~D[2031-08-08],
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
        starts_on: ~D[2030-10-01],
        ends_on: ~D[2030-10-08],
        vacation_id: herbstferien.id,
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
        starts_on: ~D[2030-12-22],
        ends_on: ~D[2031-01-05],
        vacation_id: weihnachtsferien.id,
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
        starts_on: ~D[2030-12-22],
        ends_on: ~D[2031-01-01],
        vacation_id: weihnachtsferien.id,
        location_id: hessen.id,
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    {:ok, _false_federal_state} =
      Maps.create_location(%{
        name: "Not active Example Federal State",
        level_id: bundesland.id,
        parent_id: deutschland.id,
        is_active: false
      })

    today = ~D[2030-07-01]
    year = today.year

    conn = get(conn, ~p"/?datum=2030-07-01")
    assert html_response(conn, 200) =~ "Schulferien Deutschland"
    assert html_response(conn, 200) =~ "Sommer"
    assert html_response(conn, 200) =~ "01.07. - 08.08."
    assert html_response(conn, 200) =~ "Hessen"
    assert html_response(conn, 200) =~ "Herbst"
    refute html_response(conn, 200) =~ "Not active Example Federal State"

    assert html_response(conn, 200) =~ "#{year}"
  end

  test "GET /datenschutzerklaerung", %{conn: conn} do
    conn = get(conn, ~p"/datenschutzerklaerung")
    assert html_response(conn, 200) =~ "Datenschutzerklärung"
  end
end

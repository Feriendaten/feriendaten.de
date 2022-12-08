defmodule FeriendatenWeb.FerienControllerTest do
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

    {:ok, osterferien} =
      Feriendaten.Calendars.create_vacation(%{
        name: "Ostern",
        colloquial: "Osterferien",
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
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
        starts_on: ~D[2039-12-22],
        ends_on: ~D[2040-01-05],
        vacation_id: weihnachtsferien.id,
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
        starts_on: ~D[2040-03-20],
        ends_on: ~D[2040-04-04],
        vacation_id: osterferien.id,
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
        starts_on: ~D[2040-03-20],
        ends_on: ~D[2040-04-04],
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
        starts_on: ~D[2040-10-01],
        ends_on: ~D[2040-10-14],
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
        starts_on: ~D[2039-12-22],
        ends_on: ~D[2040-01-10],
        vacation_id: weihnachtsferien.id,
        location_id: bayern.id,
        listed: true,
        for_students: true,
        for_everybody: false,
        priority: 5,
        public_holiday: false,
        school_vacation: true
      })

    conn = get(conn, ~p"/ferien/hessen?datum=2039-12-20")
    assert html_response(conn, 200) =~ "Schulferien Hessen"
    assert html_response(conn, 200) =~ "Weihnachtsferien"
    assert html_response(conn, 200) =~ "22.12. - 05.01."
    assert html_response(conn, 200) =~ "Osterferien"
    assert html_response(conn, 200) =~ "20.03. - 04.04."
    refute html_response(conn, 200) =~ "22.12. - 10.01."

    conn = get(conn, ~p"/ferien/hessen/2040")
    assert html_response(conn, 200) =~ "Schulferien Hessen 2040"
    assert html_response(conn, 200) =~ "Weihnachtsferien"
    assert html_response(conn, 200) =~ "22.12. - 05.01."
    assert html_response(conn, 200) =~ "Osterferien"
    assert html_response(conn, 200) =~ "20.03. - 04.04."
    refute html_response(conn, 200) =~ "22.12. - 10.01."

    conn = get(conn, ~p"/ferien/hessen/2040-2041")
    assert html_response(conn, 200) =~ "Schulferien Hessen Schuljahr 2040-2041"
    refute html_response(conn, 200) =~ "Weihnachtsferien"
    refute html_response(conn, 200) =~ "22.12. - 05.01."
    refute html_response(conn, 200) =~ "Osterferien"
    refute html_response(conn, 200) =~ "20.03. - 04.04."
    refute html_response(conn, 200) =~ "22.12. - 10.01."
    assert html_response(conn, 200) =~ "Herbstferien"
    assert html_response(conn, 200) =~ "01.10. - 14.10."

    conn = get(conn, ~p"/ferien/")
    assert html_response(conn, 200) =~ "Jahres- und Schuljahresübersicht"
  end
end

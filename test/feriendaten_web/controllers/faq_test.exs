defmodule FeriendatenWeb.FaqTest do
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

    for %{
          starts_on: starts_on,
          ends_on: ends_on,
          vacation_id: vacation_id,
          location_id: location_id
        } <- [
          %{
            starts_on: ~D[2039-12-22],
            ends_on: ~D[2040-01-05],
            vacation_id: weihnachtsferien.id,
            location_id: hessen.id
          },
          %{
            starts_on: ~D[2040-04-01],
            ends_on: ~D[2040-04-21],
            vacation_id: osterferien.id,
            location_id: hessen.id
          },
          %{
            starts_on: ~D[2040-07-20],
            ends_on: ~D[2040-08-04],
            vacation_id: sommerferien.id,
            location_id: hessen.id
          },
          %{
            starts_on: ~D[2040-10-01],
            ends_on: ~D[2040-10-07],
            vacation_id: herbstferien.id,
            location_id: hessen.id
          },
          %{
            starts_on: ~D[2040-10-01],
            ends_on: ~D[2040-10-14],
            vacation_id: herbstferien.id,
            location_id: bayern.id
          },
          %{
            starts_on: ~D[2040-04-01],
            ends_on: ~D[2040-04-14],
            vacation_id: osterferien.id,
            location_id: bayern.id
          },
          %{
            starts_on: ~D[2040-07-20],
            ends_on: ~D[2040-08-04],
            vacation_id: sommerferien.id,
            location_id: bayern.id
          },
          %{
            starts_on: ~D[2040-10-01],
            ends_on: ~D[2040-10-07],
            vacation_id: herbstferien.id,
            location_id: bayern.id
          },
          %{
            starts_on: ~D[2040-10-01],
            ends_on: ~D[2040-10-14],
            vacation_id: herbstferien.id,
            location_id: hessen.id
          },
          %{
            starts_on: ~D[2040-04-01],
            ends_on: ~D[2040-04-14],
            vacation_id: osterferien.id,
            location_id: hessen.id
          },
          %{
            starts_on: ~D[2040-07-20],
            ends_on: ~D[2040-08-04],
            vacation_id: sommerferien.id,
            location_id: hessen.id
          }
        ] do
      {:ok, _entry} =
        Feriendaten.Calendars.create_entry(%{
          starts_on: starts_on,
          ends_on: ends_on,
          vacation_id: vacation_id,
          location_id: location_id,
          listed: true,
          for_students: true,
          for_everybody: false,
          priority: 5,
          public_holiday: false,
          school_vacation: true
        })
    end

    conn = get(conn, ~p"/herbstferien/hessen/2040?datum=2040-01-01")
    assert html_response(conn, 200) =~ "Herbstferien Hessen 2040"
    assert html_response(conn, 200) =~ "01.10. - 07.10."
    assert html_response(conn, 200) =~ "FAQ"
    assert html_response(conn, 200) =~ "Wann sind 2040 Herbstferien in Hessen?"

    assert html_response(conn, 200) =~
             "Die Herbstferien in Hessen beginnen am 01.10.2040 (ein Montag). Bis dahin sind es noch 274 Tage."

    refute html_response(conn, 200) =~ "Wann beginnen die Herbstferien in Hessen?"

    conn = get(conn, ~p"/herbstferien/hessen?datum=2040-01-01")
    assert html_response(conn, 200) =~ "Wann beginnen die Herbstferien in Hessen?"
    assert html_response(conn, 200) =~ "Wie lange sind die Herbstferien in Hessen?"

    conn = get(conn, ~p"/herbstferien/bayern/2040?datum=2040-01-01")
    assert html_response(conn, 200) =~ "Herbstferien Bayern 2040"
    assert html_response(conn, 200) =~ "01.10. - 14.10."
    assert html_response(conn, 200) =~ "FAQ"
  end
end

defmodule FeriendatenWeb.PageController do
  use FeriendatenWeb, :controller

  def index(conn, _params) do
    locations = Feriendaten.Maps.list_locations_by_level_name("Bundesland")

    start_date = conn.assigns.requested_date
    end_date = Date.add(start_date, 250)

    entries =
      Feriendaten.Calendars.school_vacation_periods_for_germany(
        start_date,
        end_date
      )

    federal_states =
      entries
      |> Enum.map(fn l -> %{name: l.location_name, slug: l.location_slug} end)
      |> Enum.uniq()
      |> Enum.sort()

    vacations = entries |> Enum.map(fn l -> l.colloquial end) |> Enum.uniq()

    conn
    |> put_root_layout(:ferien)
    |> assign(:year, nil)
    |> assign(:location, nil)
    |> assign(:locations, locations)
    |> assign(:entries, entries)
    |> assign(:federal_states, federal_states)
    |> assign(:vacations, vacations)
    |> assign(:nav_bar_entries, [])
    |> render(:index, page_title: "Schulferien Deutschland")
  end

  def datenschutzerklaerung(conn, _params) do
    conn
    |> assign(:location, nil)
    |> assign(:entries, nil)
    |> assign(:end_date, nil)
    |> assign(:year, nil)
    |> assign(:nav_bar_entries, [
      ["Datenschutzerklärung", ~p"/datenschutzerklaerung"]
    ])
    |> put_root_layout(:ferien)
    |> render(:datenschutzerklaerung)
  end
end

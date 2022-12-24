defmodule FeriendatenWeb.PageController do
  use FeriendatenWeb, :controller

  def index(conn, _params) do
    locations = Feriendaten.Maps.list_locations_by_level_name("Bundesland")

    start_date = conn.assigns.requested_date
    end_date = Date.add(start_date, 300)

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

    # Dirty hack to make sure that "Himmelfahrtsferien" and
    # "Himmelfahrt- und Pfingsferien" are displayed and not
    # just one of them.
    #
    vacations =
      if Enum.member?(
           ["Himmelfahrtsferien", "Himmelfahrt- und Pfingsferien"],
           Enum.at(vacations, 4)
         ) &&
           !Enum.member?(
             ["Himmelfahrtsferien", "Himmelfahrt- und Pfingsferien"],
             Enum.at(vacations, 3)
           ) do
        [
          Enum.at(vacations, 0),
          Enum.at(vacations, 1),
          Enum.at(vacations, 2),
          Enum.at(vacations, 3)
        ]
      else
        [
          Enum.at(vacations, 0),
          Enum.at(vacations, 1),
          Enum.at(vacations, 2),
          Enum.at(vacations, 3),
          Enum.at(vacations, 4)
        ]
      end
      |> Enum.filter(fn v -> v != nil end)

    entries = Enum.filter(entries, fn entry -> Enum.member?(vacations, entry.colloquial) end)

    conn
    |> put_root_layout(:ferien)
    |> assign(:year, nil)
    |> assign(:location, nil)
    |> assign(:locations, locations)
    |> assign(:entries, entries)
    |> assign(:federal_states, federal_states)
    |> assign(:vacations, vacations)
    |> assign(:nav_bar_entries, [""])
    |> assign(
      :description,
      "Übersicht der Schulferien in Deutschland. Schnell und einfach planen und immer auf dem Laufenden bleiben."
    )
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
    |> assign(
      :description,
      "Datenschutzerklärung der feriendaten.de Webseite."
    )
    |> put_root_layout(:ferien)
    |> render(:datenschutzerklaerung)
  end
end

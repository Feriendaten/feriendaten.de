defmodule FeriendatenWeb.FerienController do
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
    |> assign(:nav_bar_entries, ["Ferien"])
    |> assign(
      :description,
      "Jahres- und Schuljahresübersicht der Schulferien in Deutschland für alle Bundesländer."
    )
    |> render(:index, page_title: "Schulferien Jahres- und Schuljahresübersicht")
  end

  def location(conn, %{"slug" => slug} = _params) do
    location = Feriendaten.Maps.get_location_by_slug!(slug)
    requested_date = conn.assigns.requested_date
    end_date = end_date(requested_date)

    entries =
      Feriendaten.Calendars.school_vacation_periods(
        location,
        requested_date,
        end_date
      )
      |> Feriendaten.Calendars.compress_ferientermine()

    description =
      "Schulferien #{location.name}. " <>
        Feriendaten.Calendars.join_all_colloquials_and_ferientermine(entries)

    conn
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:end_date, end_date)
    |> assign(:year, nil)
    |> assign(:requested_date, requested_date)
    |> assign(:nav_bar_entries, [
      ["Ferien", ~p"/ferien/"],
      location.name
    ])
    |> assign(:description, description)
    |> put_root_layout(:ferien)
    |> render(:location, page_title: "Ferien #{location.name}")
  end

  def year(conn, %{"slug" => slug, "year" => year} = params) do
    case String.length(year) do
      4 ->
        calendar_year(conn, params)

      9 ->
        school_year(conn, params)

      _ ->
        conn
        |> put_flash(:error, "Ungültige Jahresangabe")
        |> redirect(to: "/ferien/#{slug}")
        |> halt()
    end
  end

  def calendar_year(conn, %{"slug" => slug, "year" => year} = _params) do
    location = Feriendaten.Maps.get_location_by_slug!(slug)
    start_date = Date.from_iso8601!(year <> "-01-01")
    end_date = Date.from_iso8601!(year <> "-12-31")

    entries =
      Feriendaten.Calendars.school_vacation_periods(
        location,
        start_date,
        end_date
      )
      |> Feriendaten.Calendars.compress_ferientermine()

    description =
      "Termine und weiter Informationen der Schulferien #{location.name} #{year}. " <>
        Feriendaten.Calendars.join_all_colloquials_and_ferientermine(entries)

    conn
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:end_date, end_date)
    |> assign(:year, year)
    |> assign(:is_school_year, false)
    |> assign(:nav_bar_entries, [
      ["Ferien", ~p"/ferien/"],
      [location.name, ~p"/ferien/#{location.slug}"],
      year
    ])
    |> assign(:description, description)
    |> put_root_layout(:ferien)
    |> render(:year, page_title: "Ferien #{location.name} #{year}")
  end

  def school_year(conn, %{"slug" => slug, "year" => school_year} = _params) do
    [start_year, end_year] = String.split(school_year, "-")

    if end_year != Integer.to_string(String.to_integer(start_year) + 1) do
      if start_year == end_year do
        conn
        |> redirect(to: "/ferien/#{slug}/#{start_year}")
        |> halt()
      else
        conn
        |> put_flash(:error, "Ungültiges Schuljahr")
        |> redirect(to: "/ferien/#{slug}/#{start_year}-#{String.to_integer(start_year) + 1}")
      end
    else
      location = Feriendaten.Maps.get_location_by_slug!(slug)
      start_date = Date.from_iso8601!(start_year <> "-08-01")
      end_date = Date.from_iso8601!(end_year <> "-07-31")

      entries =
        case Feriendaten.Calendars.compress_ferientermine(
               Feriendaten.Calendars.school_vacation_periods(
                 location,
                 start_date,
                 end_date
               )
             ) do
          [first_entry | school_year_entries] ->
            if first_entry.colloquial == "Sommerferien" do
              school_year_entries
            else
              [first_entry | school_year_entries]
            end

          _ ->
            []
        end

      school_year_slug = "#{start_year}-#{String.to_integer(start_year) + 1}"

      description =
        "Schulferien #{location.name} im Schuljahr #{school_year_slug}. " <>
          Feriendaten.Calendars.join_all_colloquials_and_ferientermine(entries)

      conn
      |> assign(:location, location)
      |> assign(:entries, entries)
      |> assign(:end_date, end_date)
      |> assign(:year, start_year)
      |> assign(:is_school_year, true)
      |> assign(:nav_bar_entries, [
        ["Ferien", ~p"/ferien/"],
        [location.name, ~p"/ferien/#{location.slug}"],
        school_year_slug
      ])
      |> assign(:description, description)
      |> put_root_layout(:ferien)
      |> render(:year,
        page_title: "Ferien #{location.name} Schuljahr #{school_year_slug}"
      )
    end
  end

  # If the requested date is in the last quarter of the year
  # (October, November, December) return the last day of the following year.
  # If the requested date is in the first quarter of the year
  # (January, February, March, April) return the last day of the current year.
  # Otherwise return the 1. August of the follwing year.
  defp end_date(date) do
    if date.month >= 10 do
      Date.new!(date.year + 1, 12, 31)
    else
      if date.month <= 4 do
        Date.new!(date.year, 12, 31)
      else
        Date.new!(date.year + 1, 8, 1)
      end
    end
  end
end

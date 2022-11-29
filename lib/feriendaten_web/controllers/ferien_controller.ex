defmodule FeriendatenWeb.FerienController do
  use FeriendatenWeb, :controller

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

    conn
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:end_date, end_date)
    |> assign(:year, nil)
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

    conn
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:end_date, end_date)
    |> assign(:year, year)
    |> assign(:is_school_year, false)
    |> put_root_layout(:ferien)
    |> render(:year, page_title: "Ferien #{location.name}")
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

      conn
      |> assign(:location, location)
      |> assign(:entries, entries)
      |> assign(:end_date, end_date)
      |> assign(:year, start_year)
      |> assign(:is_school_year, true)
      |> put_root_layout(:ferien)
      |> render(:year, page_title: "Ferien #{location.name}")
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

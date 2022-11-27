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

  def year(conn, %{"slug" => slug, "year" => year} = _params) do
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
    |> put_root_layout(:ferien)
    |> render(:year, page_title: "Ferien #{location.name}")
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

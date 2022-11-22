defmodule FeriendatenWeb.FerienController do
  use FeriendatenWeb, :controller

  def location(conn, %{"slug" => slug} = _params) do
    location = Feriendaten.Maps.get_location_by_slug!(slug)
    requested_date = conn.assigns.requested_date
    last_day_of_following_year = Date.new!(requested_date.year + 1, 12, 31)
    following_year = requested_date.year + 1

    entries =
      Feriendaten.Calendars.school_vacation_periods(
        location,
        requested_date,
        last_day_of_following_year
      )

    conn
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:following_year, following_year)
    |> put_root_layout(:ferien)
    |> render(:location, page_title: "Ferien #{location.name}")
  end
end

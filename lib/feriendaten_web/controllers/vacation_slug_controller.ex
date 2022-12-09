defmodule FeriendatenWeb.VacationSlugController do
  use FeriendatenWeb, :controller

  alias Feriendaten.Calendars

  def location(
        conn,
        %{"vacation_slug" => vacation_slug, "location_slug" => location_slug} = _params
      ) do
    location = Feriendaten.Maps.get_location_by_slug!(location_slug)
    requested_date = conn.assigns.requested_date

    entries =
      Calendars.vacations_of_federal_state(
        location_slug,
        vacation_slug,
        requested_date
      )

    vacation_colloquial = hd(entries) |> Map.get(:colloquial)

    conn
    |> assign(:vacation_colloquial, vacation_colloquial)
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:requested_date, requested_date)
    |> assign(:year, nil)
    |> assign(:nav_bar_entries, [
      [vacation_colloquial, ~p"/#{vacation_slug}/"],
      location.name
    ])
    |> put_root_layout(:ferien)
    |> render(:location, page_title: "#{vacation_colloquial} #{location.name}")
  end

  def year(
        conn,
        %{"vacation_slug" => vacation_slug, "location_slug" => location_slug, "year" => year} =
          _params
      ) do
    location = Feriendaten.Maps.get_location_by_slug!(location_slug)
    starts_on = Date.from_iso8601!(year <> "-01-01")
    ends_on = Date.from_iso8601!(year <> "-12-31")

    entries =
      Calendars.vacations_of_federal_state(
        location_slug,
        vacation_slug,
        starts_on,
        ends_on
      )

    vacation_colloquial = hd(entries) |> Map.get(:colloquial)

    conn
    |> assign(:vacation_colloquial, vacation_colloquial)
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:year, year)
    |> assign(:nav_bar_entries, [
      [vacation_colloquial, ~p"/#{vacation_slug}/"],
      [location.name, ~p"/#{vacation_slug}/#{location_slug}"],
      year
    ])
    |> assign(:h1_title, "#{vacation_colloquial} #{location.name} #{year}")
    |> put_root_layout(:ferien)
    |> render(:location, page_title: "#{vacation_colloquial} #{location.name} #{year}")
  end

  def index(conn, %{"vacation_slug" => vacation_slug} = _params) do
    vacation = Feriendaten.Calendars.get_vacation_by_slug!(vacation_slug)
    starts_on = conn.assigns.requested_date

    entries =
      Calendars.vacations_of_all_federal_states(
        vacation_slug,
        starts_on
      )

    conn
    |> assign(:entries, entries)
    |> assign(:nav_bar_entries, [vacation.colloquial])
    |> assign(:h1_title, "#{vacation.colloquial}")
    |> put_root_layout(:ferien)
    |> render(:index, page_title: vacation.colloquial)
  end
end

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
    vacation_slug = hd(entries) |> Map.get(:vacation_slug)

    description =
      "Alle Termine und weitere Informationen zu den #{vacation_colloquial} #{location.name}. " <>
        Feriendaten.Calendars.join_all_colloquials_and_ferientermine(entries)

    conn
    |> assign(:vacation_colloquial, vacation_colloquial)
    |> assign(:vacation_slug, vacation_slug)
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:requested_date, requested_date)
    |> assign(:year, nil)
    |> assign(:nav_bar_entries, [
      [vacation_colloquial, ~p"/#{vacation_slug}/"],
      location.name
    ])
    |> assign(:description, description)
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
    vacation_slug = hd(entries) |> Map.get(:vacation_slug)

    description =
      "Termine und weitere Informationen zu den #{vacation_colloquial} #{location.name} #{year}. " <>
        Feriendaten.Calendars.join_all_colloquials_and_ferientermine(entries)

    image_file_name = "#{vacation_slug}/#{vacation_slug}-#{location_slug}-#{year}.jpeg"

    system_path_image_file_name =
      "#{Application.app_dir(:feriendaten)}/priv/static/images/notepad/#{image_file_name}"

    termin =
      if length(entries) == 1 do
        "Termin"
      else
        "Termine"
      end

    entries_of_this_year =
      Enum.filter(entries, fn entry -> entry.starts_on.year == String.to_integer(year) end)

    twitter_card =
      if(File.exists?(system_path_image_file_name)) do
        %{
          title: "#{vacation_colloquial} #{location.name} #{year}",
          description:
            "#{termin}: #{Feriendaten.Calendars.replace_last_comma_with_und(Feriendaten.Calendars.all_ferientermine_to_string(entries_of_this_year))}",
          image: "https://feriendaten.de/images/notepad/#{image_file_name}"
        }
      else
        %{}
      end

    conn
    |> assign(:vacation_colloquial, vacation_colloquial)
    |> assign(:vacation_slug, vacation_slug)
    |> assign(:location, location)
    |> assign(:entries, entries)
    |> assign(:year, year)
    |> assign(:twitter_card, twitter_card)
    |> assign(:nav_bar_entries, [
      [vacation_colloquial, ~p"/#{vacation_slug}/"],
      [location.name, ~p"/#{vacation_slug}/#{location_slug}"],
      year
    ])
    |> assign(:h1_title, "#{vacation_colloquial} #{location.name} #{year}")
    |> assign(:description, description)
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

    description =
      "Termine und weitere Informationen zu den #{vacation.colloquial} in Deutschland. " <>
        Feriendaten.Calendars.join_all_colloquials_and_federal_states_and_ferientermine(entries)

    conn
    |> assign(:entries, entries)
    |> assign(:nav_bar_entries, [vacation.colloquial])
    |> assign(:h1_title, "#{vacation.colloquial}")
    |> assign(:description, description)
    |> put_root_layout(:ferien)
    |> render(:index, page_title: vacation.colloquial)
  end
end

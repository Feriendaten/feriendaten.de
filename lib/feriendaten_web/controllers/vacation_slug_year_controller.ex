defmodule FeriendatenWeb.VacationSlugYearController do
  use FeriendatenWeb, :controller

  alias Feriendaten.CalendarQueries

  def show(
        conn,
        %{"vacation_slug" => vacation_slug, "location_slug" => location_slug, "year" => year} =
          _params
      ) do
    location = Feriendaten.Maps.get_location_by_slug!(location_slug)
    {entries, vacation_entries} = list_entries(location, vacation_slug, year)

    if Enum.empty?(vacation_entries) do
      conn
      |> put_flash(:error, "No entries found for #{vacation_slug} #{location_slug} #{year}")
      |> redirect(to: ~p"/#{vacation_slug}/#{location_slug}")
    else
      first_entry = hd(vacation_entries)

      vacation_colloquial = first_entry.colloquial

      description =
        "Termine und weitere Informationen zu den #{vacation_colloquial} #{location.name} #{year}: " <>
          Feriendaten.Calendars.all_ferientermine_to_string(vacation_entries)

      image_file_head = "#{vacation_slug}/#{vacation_slug}-#{location_slug}-#{year}"
      image_file_name = "#{image_file_head}.jpeg"
      image_file_name_16_9 = "#{image_file_head}-16-9.jpeg"

      system_path_image_file_name =
        "#{Application.app_dir(:feriendaten)}/priv/static/images/notepad/#{image_file_name}"

      system_path_image_file_name_16_9 =
        "#{Application.app_dir(:feriendaten)}/priv/static/images/notepad/#{image_file_name_16_9}"

      entries_of_this_year =
        Enum.filter(entries, fn entry -> entry.starts_on.year == String.to_integer(year) end)

      termin =
        if length(entries_of_this_year) == 1 do
          "Termin"
        else
          "Termine"
        end

      twitter_card =
        if(File.exists?(system_path_image_file_name) || Mix.env() == :test) do
          if(File.exists?(system_path_image_file_name_16_9)) do
            %{
              title: "#{vacation_colloquial} #{location.name} #{year}",
              description:
                "#{termin}: #{Feriendaten.Calendars.replace_last_comma_with_und(Feriendaten.Calendars.all_ferientermine_to_string(entries_of_this_year))}",
              image: "https://feriendaten.de/images/notepad/#{image_file_name}",
              image_16_9: "https://feriendaten.de/images/notepad/#{image_file_name_16_9}",
              url: "https://feriendaten.de/#{vacation_slug}/#{location_slug}/#{year}"
            }
          else
            %{
              title: "#{vacation_colloquial} #{location.name} #{year}",
              description:
                "#{termin}: #{Feriendaten.Calendars.replace_last_comma_with_und(Feriendaten.Calendars.all_ferientermine_to_string(entries_of_this_year))}",
              image: "https://feriendaten.de/images/notepad/#{image_file_name}",
              image_16_9: nil,
              url: "https://feriendaten.de/#{vacation_slug}/#{location_slug}/#{year}"
            }
          end
        else
          %{}
        end

      conn
      |> assign_nav_bar_entries(
        vacation_slug,
        location_slug,
        first_entry.colloquial,
        first_entry.location_name,
        year
      )
      |> assign(:year, year)
      |> assign(:location, location)
      |> assign(:description, description)
      |> assign(:twitter_card, twitter_card)
      |> assign(:vacation_slug, vacation_slug)
      |> assign(:location_slug, location_slug)
      |> assign(:vacation_colloquial, first_entry.colloquial)
      |> assign(:location_name, first_entry.location_name)
      |> assign(
        :preposition,
        "#{if first_entry.location_name == "Saarland", do: "im", else: "in"}"
      )
      |> assign(:vacation_entries, vacation_entries)
      |> put_root_layout(:ferien)
      |> render(:show,
        page_title: "#{first_entry.colloquial} #{first_entry.location_name} #{year}"
      )
    end
  end

  def list_entries(location, vacation_slug, year) do
    entries =
      CalendarQueries.list_entries_recursively(
        location,
        Date.from_iso8601!(year <> "-01-01"),
        Date.from_iso8601!(year <> "-12-31")
      )

    vacation_entries =
      Enum.filter(entries, fn entry ->
        entry.vacation_slug == vacation_slug && entry.starts_on.year == String.to_integer(year)
      end)

    {entries, vacation_entries}
  end

  defp assign_nav_bar_entries(conn, vacation_slug, location_slug, colloquial, location_name, year) do
    conn
    |> assign(:nav_bar_entries, [
      [colloquial, ~p"/#{vacation_slug}/"],
      [
        location_name,
        ~p"/#{vacation_slug}/#{location_slug}"
      ],
      year
    ])
  end
end

defmodule Mix.Tasks.LegacyImport do
  @moduledoc "Import legacy data"
  use Mix.Task
  import Ecto.Query

  alias Feriendaten.{Repo, LegacyRepo, Maps, Legacy, Maps.Location}
  alias Feriendaten.Calendars.{Vacation, Enty}

  @requirements ["app.start"]

  @shortdoc "Import legacy data."
  def run(_) do
    create_levels()
    create_loctations_for_countries()
    create_locations_for_federal_states()
    create_locations_for_counties()
    create_locations_for_cities()
    create_locations_for_schools()
    create_addresses()
    import_vacations()
    import_legacy_entries()
  end

  defp create_levels do
    {:ok, _land} =
      Maps.create_level(%{
        name: "Land",
        order: 1
      })

    {:ok, _bundesland} =
      Maps.create_level(%{
        name: "Bundesland",
        order: 2
      })

    {:ok, _kreis} =
      Maps.create_level(%{
        name: "Landkreis",
        order: 3
      })

    {:ok, _stadt} =
      Maps.create_level(%{
        name: "Stadt",
        order: 4
      })

    {:ok, _schule} =
      Maps.create_level(%{
        name: "Schule",
        order: 5
      })
  end

  defp create_loctations_for_countries do
    query = from(l in Legacy.Location, where: l.is_country == true)
    countries = LegacyRepo.all(query)
    land = Maps.get_level_by_name!("Land")

    Enum.each(countries, fn c ->
      {:ok, _country} =
        Maps.create_location(%{
          name: c.name,
          code: c.code,
          legacy_name: c.name,
          legacy_id: c.id,
          legacy_slug: c.slug,
          legacy_parent_id: c.parent_location_id,
          level_id: land.id,
          is_active: false
        })
    end)
  end

  defp create_locations_for_federal_states do
    query = from(l in Legacy.Location, where: l.is_federal_state == true)
    federal_states = LegacyRepo.all(query)
    bundesland = Maps.get_level_by_name!("Bundesland")

    Enum.each(federal_states, fn fs ->
      query = from(l in Location, where: l.legacy_id == ^fs.parent_location_id)
      parent_country = Repo.one(query)

      {:ok, _federal_state} =
        Maps.create_location(%{
          name: fs.name,
          code: fs.code,
          legacy_name: fs.name,
          legacy_id: fs.id,
          legacy_slug: fs.slug,
          legacy_parent_id: fs.parent_location_id,
          level_id: bundesland.id,
          parent_id: parent_country.id,
          is_active: false
        })
    end)
  end

  defp create_locations_for_counties do
    query = from(l in Legacy.Location, where: l.is_county == true)
    counties = LegacyRepo.all(query)
    kreis = Maps.get_level_by_name!("Landkreis")

    Enum.each(counties, fn c ->
      query = from(l in Location, where: l.legacy_id == ^c.parent_location_id)
      parent_federal_state = Repo.one(query)

      {:ok, _county} =
        Maps.create_location(%{
          name: c.name,
          code: c.code,
          legacy_name: c.name,
          legacy_id: c.id,
          legacy_slug: c.slug,
          legacy_parent_id: c.parent_location_id,
          level_id: kreis.id,
          parent_id: parent_federal_state.id,
          is_active: false
        })
    end)
  end

  defp create_locations_for_cities do
    query = from(l in Legacy.Location, where: l.is_city == true)
    cities = LegacyRepo.all(query)
    stadt = Maps.get_level_by_name!("Stadt")

    Enum.each(cities, fn c ->
      query = from(l in Location, where: l.legacy_id == ^c.parent_location_id)
      parent_county = Repo.one(query)

      {:ok, _city} =
        Maps.create_location(%{
          name: c.name,
          code: c.code,
          legacy_name: c.name,
          legacy_id: c.id,
          legacy_slug: c.slug,
          legacy_parent_id: c.parent_location_id,
          level_id: stadt.id,
          parent_id: parent_county.id,
          is_active: false
        })
    end)
  end

  defp create_locations_for_schools do
    query = from(l in Legacy.Location, where: l.is_school == true)
    schools = LegacyRepo.all(query)
    schule = Maps.get_level_by_name!("Schule")

    Enum.each(schools, fn s ->
      query = from(l in Location, where: l.legacy_id == ^s.parent_location_id)
      parent_city = Repo.one(query)

      # Remove not needed stuff from name
      name =
        s.name
        |> String.replace("(Schule in freier Trägerschaft)", "")
        |> String.replace("(Schule in freier Trägeschaft)", "")
        |> String.replace(" in freier Trägerschaft", "")
        |> String.replace("(Schule)", "")
        |> String.replace("(Grundschule)", "")
        |> String.replace("(Integrierte Sekundarschule)", "")
        |> String.replace("(Gemeinschaftsschule)", "")
        |> String.replace("(Förderschule)", "")
        |> String.replace("(Förderschule für Körperbehinderte)", "")
        |> String.replace("(Förderschule für Geistigbehinderte)", "")
        |> String.replace("(Förderschule für Sehbehinderte)", "")
        |> String.replace("(Förderschule für Hörgeschädigte)", "")
        |> String.replace("(Förderschule für Lernbehinderte)", "")
        |> String.replace("(Förderschule für Sprachbehinderte)", "")
        |> String.replace("(Förderschule für Mehrfachbehinderte)", "")
        |> String.replace("(Förderschule für Körper- und Mehrfachbehinderte)", "")
        |> String.replace("(Gymnasium)", "")
        |> String.replace("(Stadtteilschule)", "")
        |> String.replace("(Grund- u. Hauptschulstufe)", "")
        |> String.replace("(Realschule für Mädchen)", "")
        |> String.replace("(Realschule)", "")
        |> String.replace("(privat)", "")
        |> String.replace("(kath.)", "")
        |> String.replace("(Kath. Grundschule)", "")
        |> String.replace("(Grundschule I)", "")
        |> String.replace("(Grundschule II)", "")
        |> String.replace(~r/[[:space:]]+/, " ", global: true)
        |> String.replace(~r/[[:blank:]]+/, " ", global: true)
        # Sonderzeichen
        |> String.replace("  ", " ", global: true)
        |> String.replace(" ", " ", global: true)
        |> String.replace("  ", " ", global: true)
        |> String.trim()

      {:ok, _school} =
        Maps.create_location(%{
          name: name,
          code: s.code,
          legacy_id: s.id,
          legacy_name: s.name,
          legacy_slug: s.slug,
          legacy_parent_id: s.parent_location_id,
          level_id: schule.id,
          parent_id: parent_city.id,
          is_active: false
        })
    end)
  end

  defp create_addresses do
    query = from(a in Legacy.Address)
    addresses = LegacyRepo.all(query)

    Enum.each(addresses, fn a ->
      query = from(l in Location, where: l.legacy_id == ^a.school_location_id, limit: 1)
      location = Repo.one(query)

      email =
        case a.email_address do
          nil ->
            nil

          email ->
            email
            |> String.replace("(@)", "@")
            |> String.downcase()
        end

      {:ok, _address} =
        Feriendaten.Schools.create_address(%{
          line1: location.name,
          street: a.street,
          zip_code: a.zip_code,
          city: a.city,
          location_id: location.id,
          legacy_id: a.id,
          phone: a.phone_number,
          fax: a.fax_number,
          email: email,
          url: a.homepage_url,
          lat: a.lat,
          lon: a.lon,
          school_type: a.school_type
        })
    end)
  end

  defp import_vacations do
    query = from(t in Legacy.HolidayOrVacationType)
    types = LegacyRepo.all(query)

    Enum.each(types, fn t ->
      {for_everybody, public_holiday} =
        case t.default_html_class do
          nil -> {true, true}
          _ -> {false, false}
        end

      for_everybody =
        if t.name == "Wochenende" do
          true
        else
          for_everybody
        end

      {:ok, _type} =
        unless t.colloquial == "Corona-Schulschließung" do
          Feriendaten.Calendars.create_vacation(%{
            name: t.name,
            colloquial: t.colloquial,
            listed: t.default_is_listed_below_month,
            for_students: t.default_is_valid_for_students,
            for_everybody: for_everybody,
            priority: t.default_display_priority,
            public_holiday: public_holiday,
            school_vacation: t.default_is_school_vacation,
            wikipedia_url: t.wikipedia_url,
            legacy_id: t.id
          })
        else
          {:ok, nil}
        end
    end)
  end

  defp import_legacy_entries do
    query = from(p in Legacy.Period)
    periods = LegacyRepo.all(query)

    Enum.each(periods, fn p ->
      query =
        from(v in Vacation,
          where: v.legacy_id == ^p.holiday_or_vacation_type_id
        )

      vacation = Repo.one(query)

      unless vacation == nil do
        query =
          from(l in Location,
            where: l.legacy_id == ^p.location_id
          )

        location = Repo.one(query)

        {:ok, _period} =
          Feriendaten.Calendars.create_entry(%{
            starts_on: p.starts_on,
            ends_on: p.ends_on,
            vacation_id: vacation.id,
            legacy_id: p.id,
            memo: p.memo,
            location_id: location.id,
            listed: p.is_listed_below_month,
            for_students: p.is_valid_for_students,
            for_everybody: p.is_valid_for_everybody,
            priority: p.display_priority,
            public_holiday: p.is_public_holiday,
            school_vacation: p.is_school_vacation
          })
      end
    end)
  end
end

defmodule Feriendaten.Repo.Migrations.AddWeekends do
  use Ecto.Migration

  import Ecto.Query, warn: false
  alias Feriendaten.Repo
  alias Feriendaten.Calendars
  alias Feriendaten.Maps

  def up do
    {:ok, start_date} = Date.from_iso8601("2024-01-01")
    {:ok, end_date} = Date.from_iso8601("2030-01-01")

    weekend = Calendars.get_vacation_by_slug!("wochenende")
    germany = Maps.get_location_by_slug!("deutschland")

    sundays =
      Date.range(start_date, end_date)
      |> Enum.filter(fn x -> Date.day_of_week(x) == 7 end)

    for sunday <- sundays do
      Calendars.create_entry(%{
        starts_on: Date.add(sunday, -1),
        ends_on: sunday,
        vacation_id: weekend.id,
        location_id: germany.id,
        for_everybody: true,
        for_students: false,
        public_holiday: false,
        school_vacation: false,
        listed: false
      })
    end
  end
end

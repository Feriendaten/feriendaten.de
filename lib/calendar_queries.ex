defmodule Feriendaten.CalendarQueries do
  alias Feriendaten.Maps.Location
  alias Feriendaten.Calendars.Entry

  @moduledoc """
  The CalendarQueries context.
  """

  import Ecto.Query, warn: false
  alias Feriendaten.Repo

  @doc """
  Returns a list of entries within the given date range.

  ## Examples

  iex> list_entries_recursivly(...)
  [
  %{
    colloquial: "Weihnachtsferien",
    days: 16,
    ends_on: ~D[2023-01-05],
    ferientermin: "21.12. - 05.01.",
    for_everybody: false,
    for_students: true,
    id: 990,
    level_name: "Bundesland",
    listed: true,
    location_name: "Sachsen-Anhalt",
    location_slug: "sachsen-anhalt",
    memo: nil,
    name: "Weihnachten",
    priority: 5,
    public_holiday: false,
    school_vacation: true,
    starts_on: ~D[2022-12-21],
    vacation_slug: "weihnachten"
  },
  ...
  ]
  """
  def list_entries_recursively(
        location,
        starts_on \\ Date.utc_today(),
        ends_on \\ Date.add(Date.utc_today(), 365)
      ) do
    location_tree_initial_query =
      from l in Location,
        where: l.id == ^location.id and l.is_active == true,
        select: %{id: l.id, parent_id: l.parent_id}

    location_tree_recursion_query =
      from l in Location,
        join: lt in "cte_location",
        on: lt.parent_id == l.id,
        where: l.is_active == true,
        select: %{id: l.id, parent_id: l.parent_id}

    location_tree_query =
      location_tree_initial_query
      |> union_all(^location_tree_recursion_query)

    cte_location =
      {"cte_location", Location}
      |> recursive_ctes(true)
      |> with_cte("cte_location", as: ^location_tree_query)
      |> select([l], l.id)

    query =
      from p in Entry,
        join: vacation in "vacations",
        on: p.vacation_id == vacation.id,
        join: l in "locations",
        on: p.location_id == l.id,
        join: level in "levels",
        on: l.level_id == level.id,
        where: p.ends_on >= ^starts_on,
        where: p.starts_on <= ^ends_on,
        where: vacation.for_students or vacation.for_everybody,
        where: p.location_id in subquery(cte_location),
        order_by: p.starts_on,
        order_by: vacation.priority,
        order_by: l.name,
        select: %{
          id: p.id,
          starts_on: p.starts_on,
          ends_on: p.ends_on,
          ferientermin:
            fragment(
              "CASE WHEN starts_on = ends_on THEN TO_CHAR(starts_on, 'dd.mm.') ELSE CONCAT(TO_CHAR(starts_on, 'dd.mm.'), ' - ', TO_CHAR(ends_on, 'dd.mm.')) END"
            ),
          name: vacation.name,
          colloquial: vacation.colloquial,
          days: p.ends_on - p.starts_on + 1,
          vacation_slug: vacation.slug,
          location_name: l.name,
          location_slug: l.slug,
          level_name: level.name,
          school_vacation: vacation.school_vacation,
          public_holiday: vacation.public_holiday,
          listed: vacation.listed,
          priority: vacation.priority
        }

    Repo.all(query)
  end
end

defmodule Feriendaten.Calendars do
  alias Feriendaten.Maps.Location
  alias Feriendaten.Calendars.Entry

  @moduledoc """
  The Calendars context.
  """

  import Ecto.Query, warn: false
  alias Feriendaten.Repo

  alias Feriendaten.Calendars.Vacation

  @doc """
  Returns the list of vacations.

  ## Examples

      iex> list_vacations()
      [%Vacation{}, ...]

  """
  def list_vacations do
    Repo.all(Vacation)
  end

  @doc """
  Gets a single vacation.

  Raises `Ecto.NoResultsError` if the Vacation does not exist.

  ## Examples

      iex> get_vacation!(123)
      %Vacation{}

      iex> get_vacation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vacation!(id), do: Repo.get!(Vacation, id)

  @doc """
  Creates a vacation.

  ## Examples

      iex> create_vacation(%{field: value})
      {:ok, %Vacation{}}

      iex> create_vacation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vacation(attrs \\ %{}) do
    %Vacation{}
    |> Vacation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vacation.

  ## Examples

      iex> update_vacation(vacation, %{field: new_value})
      {:ok, %Vacation{}}

      iex> update_vacation(vacation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vacation(%Vacation{} = vacation, attrs) do
    vacation
    |> Vacation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vacation.

  ## Examples

      iex> delete_vacation(vacation)
      {:ok, %Vacation{}}

      iex> delete_vacation(vacation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vacation(%Vacation{} = vacation) do
    Repo.delete(vacation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vacation changes.

  ## Examples

      iex> change_vacation(vacation)
      %Ecto.Changeset{data: %Vacation{}}

  """
  def change_vacation(%Vacation{} = vacation, attrs \\ %{}) do
    Vacation.changeset(vacation, attrs)
  end

  alias Feriendaten.Calendars.Entry

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries()
      [%Entry{}, ...]

  """
  def list_entries do
    Repo.all(Entry)
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(123)
      %Entry{}

      iex> get_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id), do: Repo.get!(Entry, id)

  @doc """
  Creates a entry.

  ## Examples

      iex> create_entry(%{field: value})
      {:ok, %Entry{}}

      iex> create_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry(attrs \\ %{}) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a entry.

  ## Examples

      iex> update_entry(entry, %{field: new_value})
      {:ok, %Entry{}}

      iex> update_entry(entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry(%Entry{} = entry, attrs) do
    entry
    |> Entry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a entry.

  ## Examples

      iex> delete_entry(entry)
      {:ok, %Entry{}}

      iex> delete_entry(entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry(%Entry{} = entry) do
    Repo.delete(entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes.

  ## Examples

      iex> change_entry(entry)
      %Ecto.Changeset{data: %Entry{}}

  """
  def change_entry(%Entry{} = entry, attrs \\ %{}) do
    Entry.changeset(entry, attrs)
  end

  @doc """
    Returns a list of school vacation periods for the given location and date range.

    ## Examples

    iex> koblenz = get_location!(325)
    iex> school_vacation_periods(koblenz)

    The underlining SQL code for this:

    SELECT
      periods.id,
      periods.starts_on,
      periods.ends_on,
      holiday_or_vacation_types.name,
      holiday_or_vacation_types.colloquial,
      periods.ends_on - periods.starts_on + 1 AS days,
      holiday_or_vacation_types.slug
    FROM
      periods
      INNER JOIN holiday_or_vacation_types ON periods.holiday_or_vacation_type_id = holiday_or_vacation_types.id
    WHERE
      periods.ends_on >= '2022-09-20'
      AND periods.starts_on <= '2023-12-31'
      AND holiday_or_vacation_types.school_vacation = TRUE
      AND location_id IN(WITH RECURSIVE cte_location AS (
          SELECT
            id,
            parent_id FROM locations
          WHERE
            id = 325
          UNION ALL
          SELECT
            e.id,
            e.parent_id FROM locations e
            INNER JOIN cte_location o ON o.parent_id = e.id
    )
    SELECT
      id FROM cte_location)
    ORDER BY
      periods.starts_on;
  """
  def school_vacation_periods(%Location{} = location, starts_on, ends_on) do
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
        join: type in "vacations",
        on: p.vacation_id == type.id,
        join: l in "locations",
        on: p.location_id == l.id,
        join: level in "levels",
        on: l.level_id == level.id,
        where: p.ends_on >= ^starts_on,
        where: p.starts_on <= ^ends_on,
        where: type.school_vacation,
        where: p.location_id in subquery(cte_location),
        order_by: p.starts_on,
        select: %{
          id: p.id,
          starts_on: p.starts_on,
          ends_on: p.ends_on,
          name: type.name,
          colloquial: type.colloquial,
          days: p.ends_on - p.starts_on + 1,
          vacation_slug: type.slug,
          location_name: l.name,
          location_slug: l.slug,
          level_name: level.name,
          school_vacation: type.school_vacation,
          public_holiday: type.public_holiday,
          listed: type.listed,
          for_everybody: type.for_everybody,
          for_students: type.for_students,
          wikipedia_url: type.wikipedia_url,
          memo: p.memo,
          priority: type.priority
        }

    Repo.all(query)
    |> Enum.map(fn period ->
      ferientermin =
        if period.starts_on == period.ends_on do
          Calendar.strftime(period.ends_on, "%d.%m.")
        else
          "#{Calendar.strftime(period.starts_on, "%d.%m.")} - #{Calendar.strftime(period.ends_on, "%d.%m.")}"
        end

      Map.put(period, :ferientermin, ferientermin)
    end)
  end

  @doc """
  Returns a list of school vacation periods for Germany within the given date range.

  ## Examples

  iex> school_vacation_periods_for_germany()
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
    vacation_slug: "weihnachten",
    wikipedia_url: "https://de.m.wikipedia.org/wiki/Schulferien#Weihnachtsferien"
  },
  ...
  ]
  """
  def school_vacation_periods_for_germany(
        starts_on \\ Date.utc_today(),
        ends_on \\ Date.add(Date.utc_today(), 365)
      ) do
    location_tree_initial_query =
      from l in Location,
        where: l.parent_id == 1 and l.is_active == true,
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
        join: type in "vacations",
        on: p.vacation_id == type.id,
        join: l in "locations",
        on: p.location_id == l.id,
        join: level in "levels",
        on: l.level_id == level.id,
        where: p.ends_on >= ^starts_on,
        where: p.starts_on <= ^ends_on,
        where: type.school_vacation,
        where: p.location_id in subquery(cte_location),
        order_by: p.starts_on,
        select: %{
          id: p.id,
          starts_on: p.starts_on,
          ends_on: p.ends_on,
          name: type.name,
          colloquial: type.colloquial,
          days: p.ends_on - p.starts_on + 1,
          vacation_slug: type.slug,
          location_name: l.name,
          location_slug: l.slug,
          level_name: level.name,
          school_vacation: type.school_vacation,
          public_holiday: type.public_holiday,
          listed: type.listed,
          for_everybody: type.for_everybody,
          for_students: type.for_students,
          wikipedia_url: type.wikipedia_url,
          memo: p.memo,
          priority: type.priority
        }

    Repo.all(query)
    |> Enum.map(fn period ->
      ferientermin =
        if period.starts_on == period.ends_on do
          Calendar.strftime(period.ends_on, "%d.%m.")
        else
          "#{Calendar.strftime(period.starts_on, "%d.%m.")} - #{Calendar.strftime(period.ends_on, "%d.%m.")}"
        end

      Map.put(period, :ferientermin, ferientermin)
    end)
  end

  @doc """
    Returns a compressed list of school vacation periods. Vacations which
    have multiple entries are summed up and only listed once.

    %{
      colloquial: "Osterferien",
      days: 14,                                     <--- This is the sum of all days
      ends_on: ~D[2022-03-07],
      ferientermin: "07.03. und 11.04. - 23.04.",   <--- This summarizes all dates.
      holiday_or_vacation_type_slug: "ostern-fruehjahr",
      id: 962,
      level_name: "Bundesland",
      location_slug: "berlin",
      name: "Ostern/Frühjahr",
      starts_on: ~D[2022-03-07]
    },
  """
  def compress_ferientermine([
        %{colloquial: prefix} = left,
        %{colloquial: prefix} = right | other_lists
      ]) do
    left =
      left
      |> Map.replace(:ferientermin, "#{left.ferientermin}, #{right.ferientermin}")
      |> Map.replace(:days, left.days + right.days)

    compress_ferientermine([left | other_lists])
  end

  def compress_ferientermine([left, right | other_lists]) do
    [left | compress_ferientermine([right | other_lists])]
  end

  def compress_ferientermine([left]) do
    [left | compress_ferientermine([])]
  end

  def compress_ferientermine([]), do: []

  @doc """
    Fixes a potential missing "und" in the ferientermin field.

    ## Examples

    iex> replace_last_comma_with_and("1, 2, 3")
    "1, 2 und 3"
  """
  def replace_last_comma_with_und(string) do
    Regex.replace(~r/, [^,]*$/, string, " und \\0")
    |> String.replace(" und ,", " und")
  end

  @doc """
    Filter a list of periods for school vacations.
  """
  def filter_for_school_vacation(periods) do
    Enum.filter(periods, fn period -> period.school_vacation end)
  end

  @doc """
  Returns a list of specific school vacation periods for the given federal state.

  ## Examples

  iex> vacations_of_federal_state("sachsen-anhalt", "weihnachtsferien")
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
    vacation_slug: "weihnachten",
    wikipedia_url: "https://de.m.wikipedia.org/wiki/Schulferien#Weihnachtsferien"
  },
  ...
  ]
  """
  def vacations_of_federal_state(
        location_slug,
        vacation_slug,
        starts_on \\ Date.utc_today(),
        ends_on \\ Date.add(Date.utc_today(), 7300)
      ) do
    query =
      from p in Entry,
        join: type in "vacations",
        on: p.vacation_id == type.id,
        join: l in "locations",
        on: p.location_id == l.id,
        where: l.slug == ^location_slug,
        where: type.slug == ^vacation_slug,
        where: p.ends_on >= ^starts_on,
        where: p.starts_on <= ^ends_on,
        order_by: p.starts_on,
        select: %{
          starts_on: p.starts_on,
          ends_on: p.ends_on,
          name: type.name,
          colloquial: type.colloquial,
          days: p.ends_on - p.starts_on + 1,
          vacation_slug: type.slug,
          location_name: l.name,
          location_slug: l.slug
        }

    Repo.all(query)
    |> Enum.map(fn period ->
      ferientermin =
        if period.starts_on == period.ends_on do
          Calendar.strftime(period.ends_on, "%d.%m.")
        else
          "#{Calendar.strftime(period.starts_on, "%d.%m.")} - #{Calendar.strftime(period.ends_on, "%d.%m.")}"
        end

      Map.put(period, :ferientermin, ferientermin)
    end)
  end
end

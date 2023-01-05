defmodule Feriendaten.GapsAndIslands do
  @moduledoc """
  The GapsAndIslands context.
  """

  import Ecto.Query, warn: false
  alias Feriendaten.Repo

  @doc """
  Returns a recursive list of school vacation entries for the given location.

  ## Example

  iex> location = Feriendaten.Maps.get_location_by_slug!("brandenburg")
  iex> list_school_vacation_entries_recursively(location, ~D[2023-01-20], ~D[2023-02-28])
  [
  %{
    days: 5,
    ends_on: ~D[2023-02-03],
    entries_agg: [1087, 1374, 1419],
    entry_id: 1087,
    federal_state_name: "Brandenburg",
    federal_state_slug: "brandenburg",
    ferientermin: "30.01. - 03.02.",
    ferientermin_long: "30.01.23 - 03.02.23",
    for_everybody: false,
    for_students: true,
    level_name: "Bundesland",
    levels_agg: "[5, 1]",
    listed: true,
    location_name: "Brandenburg",
    location_slug: "brandenburg",
    memo: nil,
    priority: 5,
    public_holiday: false,
    real_end: ~D[2023-02-05],
    real_start: ~D[2023-01-28],
    school_vacation: true,
    starts_on: ~D[2023-01-30],
    total_vacation_length: 9,
    vacation_colloquial: "Winterferien",
    vacation_name: "Winter",
    vacation_slug: "winterferien"
  }
  ]
  """
  def list_school_vacation_entries_recursively(
        location,
        starts_on \\ Date.utc_today(),
        ends_on \\ Date.add(Date.utc_today(), 30)
      ) do
    sql_query = ~S"""
    with recursive cte(location_id, parent_id) as (
    -- recursive cte to find the all the levels ("regions") that the location falls under
    select loc.id, loc.parent_id from locations loc where loc.id = to_be_replaced_location_id -- specificing location id
    union all
    select loc.id, loc.parent_id from locations loc join cte c on c.parent_id = loc.id
    ),
    days_with_vacations as (
    -- generates a range of days from start on and end on and joins all the possible holidays/vacations on to each of those dates
    select all_days.dt, ent.school_vacation, all_days.levels, ent.id * case when ent.school_vacation then 1 else 0 end entry_id, ent.id entry_id_legacy, ent.starts_on, ent.ends_on from (
    	select date(d) dt, (select json_agg(c.location_id) from cte c) levels
    		from generate_series('to_be_replaced_starts_on', 'to_be_replaced_ends_on', interval '1 day') d) all_days -- here is where the desired day range is placed
    left join entries ent on exists (select 1 from json_array_elements(all_days.levels) v
    				where ent.location_id = (v.value#>>'{}')::int)
    				and all_days.dt <= ent.ends_on and ent.starts_on <= all_days.dt
    				and (ent.for_everybody or ent.for_students)
    ),
    prior_vacation_days as (
    select all_days.dt, ent.school_vacation, all_days.levels, ent.id * case when ent.school_vacation then 1 else 0 end entry_id, ent.id entry_id_legacy, ent.starts_on, ent.ends_on from (
    select date('to_be_replaced_starts_on'::timestamp - interval '1 day') dt, (select json_agg(c.location_id) from cte c) levels
    ) all_days
    join entries ent on exists (select 1 from json_array_elements(all_days.levels) v
    				where ent.location_id = (v.value#>>'{}')::int)
    				and all_days.dt <= ent.ends_on and ent.starts_on <= all_days.dt
    				and (ent.for_everybody or ent.for_students)
    union all
    select date(prior_days.dt - interval '1 day') dt, ent.school_vacation, prior_days.levels, ent.id * case when ent.school_vacation then 1 else 0 end entry_id, ent.id entry_id_legacy, ent.starts_on, ent.ends_on
    from prior_vacation_days prior_days
    join entries ent on exists (select 1 from json_array_elements(prior_days.levels) v
    				where ent.location_id = (v.value#>>'{}')::int)
    				and (prior_days.dt - interval '1 day') <= ent.ends_on and ent.starts_on <= (prior_days.dt - interval '1 day')
    				and (ent.for_everybody or ent.for_students)
    ),
    next_vacation_days as (
    select all_days.dt, ent.school_vacation, all_days.levels, ent.id * case when ent.school_vacation then 1 else 0 end entry_id, ent.id entry_id_legacy, ent.starts_on, ent.ends_on from (
    select date('to_be_replaced_ends_on'::timestamp + interval '1 day') dt, (select json_agg(c.location_id) from cte c) levels
    ) all_days
    join entries ent on exists (select 1 from json_array_elements(all_days.levels) v
    				where ent.location_id = (v.value#>>'{}')::int)
    				and all_days.dt <= ent.ends_on and ent.starts_on <= all_days.dt
    				and (ent.for_everybody or ent.for_students)
    union all
    select date(next_days.dt + interval '1 day') dt, ent.school_vacation, next_days.levels, ent.id * case when ent.school_vacation then 1 else 0 end entry_id, ent.id entry_id_legacy, ent.starts_on, ent.ends_on
    from next_vacation_days next_days
    join entries ent on exists (select 1 from json_array_elements(next_days.levels) v
    				where ent.location_id = (v.value#>>'{}')::int)
    				and (next_days.dt + interval '1 day') <= ent.ends_on and ent.starts_on <= (next_days.dt + interval '1 day')
    				and (ent.for_everybody or ent.for_students)
    ),
    full_days_with_vacations as (
    select t.* from (
    select * from prior_vacation_days
    union all
    select * from days_with_vacations
    union all
    select * from next_vacation_days
    ) t
    order by t.dt
    )
    select vacations.entry_id,
    		vacations.levels_agg,
    		vacations_master.name vacation_name,
    		vacations_master.colloquial vacation_colloquial,
    		vacations_master.colloquial colloquial,
    		vacations_master.slug vacation_slug,
    		vacations.entries_agg,
    		ent.starts_on,
    		ent.ends_on,
    		lpad(extract(day from ent.starts_on)::text, 2, '0')||'.'||lpad(extract(month from ent.starts_on)::text, 2, '0')||'. - '||lpad(extract(day from ent.ends_on)::text, 2, '0')||'.'||lpad(extract(month from ent.ends_on)::text, 2, '0')||'.' ferientermin,
    		lpad(extract(day from ent.starts_on)::text, 2, '0')||'.'||lpad(extract(month from ent.starts_on)::text, 2, '0')||'.'||extract(year from ent.starts_on)::int%100||' - '||lpad(extract(day from ent.ends_on)::text, 2, '0')||'.'||lpad(extract(month from ent.ends_on)::text, 2, '0')||'.'||extract(year from ent.ends_on)::int%100 ferientermin_long,
    		ent.for_everybody,
    		ent.for_students,
    		levels.name level_name,
    		ent.listed,
    		loc.name location_name,
    		loc.slug location_slug,
    		ent.memo,
    		vacations_master.priority,
    		ent.public_holiday,
    		ent.school_vacation,
    		vacations_master.for_everybody,
    		vacations_master.for_students,
    		federal_state.name federal_state_name,
    		federal_state.slug federal_state_slug,
    		vacations.real_start,
    		vacations.real_end,
    		ent.ends_on - ent.starts_on + 1 days,
    		vacations.real_end - vacations.real_start + 1 total_vacation_length
    from (
    select temp_days_with_vacations.group_num,
    		-- here, the query creates the "islands" of vacation time
    		-- below, each "island" is checked to see if valid vacation days (i.e entries.school_vacation = true) exists in it, and then gets the minimum and maximum dates in island, corresponding to the real_start and real_end
    		min(temp_days_with_vacations.dt) real_start,
    		max(temp_days_with_vacations.dt) real_end,
    		max(temp_days_with_vacations.levels::text) levels_agg,
    		max(temp_days_with_vacations.entry_id) entry_id,
    		json_agg(distinct temp_days_with_vacations.entry_id_legacy) entries_agg
    from  (select (select sum(case when v.dt <= days.dt and v.school_vacation is null then 1 else 0 end) group_num from full_days_with_vacations v), days.*
    							from full_days_with_vacations days
    order by days.dt) temp_days_with_vacations
    where temp_days_with_vacations.school_vacation is not null
    group by temp_days_with_vacations.group_num) vacations
    join entries ent on ent.id = vacations.entry_id
    join vacations vacations_master on vacations_master.id = ent.vacation_id
    join locations loc on (vacations.levels_agg::json ->> 0)::int = loc.id
    join locations federal_state on (vacations.levels_agg::json ->> json_array_length(vacations.levels_agg::json) - 2)::int = federal_state.id
    join levels on levels.id = loc.level_id
    """

    sql_query =
      sql_query
      |> String.replace("to_be_replaced_location_id", to_string(location.id))
      |> String.replace("to_be_replaced_starts_on", Date.to_string(starts_on))
      |> String.replace("to_be_replaced_ends_on", Date.to_string(ends_on))

    sql_result = Ecto.Adapters.SQL.query!(Repo, sql_query, [])

    Enum.map(sql_result.rows, fn row ->
      columns = Enum.map(sql_result.columns, &String.to_atom/1)
      Map.new(Enum.zip(columns, row))
    end)
  end
end

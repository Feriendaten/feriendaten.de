defmodule Feriendaten.GapsAndIslands do
  alias Feriendaten.Maps.Location
  alias Feriendaten.Calendars.Entry

  @moduledoc """
  The GapsAndIslands context.
  """

  import Ecto.Query, warn: false
  alias Feriendaten.Repo

  def list_entries_recursively(
        location,
        starts_on \\ Date.utc_today(),
        ends_on \\ Date.add(Date.utc_today(), 30)
      ) do
    sql_query = ~S"""
    WITH RECURSIVE cte AS (
    	SELECT
    		l.*,
    		jsonb_build_array (l.id) tree
    	FROM
    		locations l
    	WHERE
    		l.parent_id IS NULL
    	UNION ALL
    	SELECT
    		l.*,
    		c.tree || jsonb_build_array (l.id)
    	FROM
    		cte c
    		JOIN locations l ON l.parent_id = c.id
    ),
    get_vacations (
    	id,
    	t,
    	h_id,
    	r_s,
    	r_e
    ) AS (
    	SELECT
    		c.id,
    		c.tree,
    		e.id,
    		e.starts_on,
    		e.ends_on
    	FROM
    		cte c
    		JOIN entries e ON EXISTS (
    			SELECT
    				1
    			FROM
    				jsonb_array_elements(c.tree) v
    			WHERE (v.value #>>'{}')::int = e.location_id)
    			WHERE
    				c.id = required_location_id -- SEARCH CRITERIA
    				AND e.vacation_id = 2 -- SEARCH CRITERIA
    			UNION ALL
    			SELECT
    				g.id,
    				g.t,
    				g.h_id,
    				least(e.starts_on,
    					g.r_s),
    				greatest(e.ends_on,
    					g.r_e)
    			FROM
    				get_vacations g
    				JOIN entries e ON EXISTS (
    					SELECT
    						1
    					FROM
    						jsonb_array_elements(g.t) v
    					WHERE (v.value #>>'{}')::int = e.location_id)
    						AND e.starts_on = g.r_e
    						OR e.ends_on = g.r_s
    )
    				SELECT
    					e.starts_on,
    					e.ends_on,
    					e.ends_on - e.starts_on days,
    					e.for_everybody,
    					e.school_vacation,
    					l.name location_name,
    					t.r_e - t.r_s total_days,
    					t.t aggr_location_ids,
    					t.r_s real_start,
    					t.r_e real_end
    				FROM (
    					SELECT
    						g.id,
    						g.t,
    						g.h_id,
    						min(g.r_s) r_s,
    						max(g.r_e) r_e
    					FROM
    						get_vacations g
    					GROUP BY
    						g.id,
    						g.t,
    						g.h_id) t
    					JOIN entries e ON e.id = t.h_id
    					JOIN locations l ON l.id = (t.t ->> 1)::int
    """

    sql_query = String.replace(sql_query, "required_location_id", to_string(location.id))

    sql_result = Ecto.Adapters.SQL.query!(Repo, sql_query, [])

    # Enum.map(sql_result.rows, fn row ->
    #   columns = Enum.map(sql_result.columns, &String.to_existing_atom/1)
    #   Map.new(Enum.zip(columns, row))
    # end)

    Enum.map(sql_result.rows, fn row ->
      Map.new(Enum.zip(sql_result.columns, row))
    end)
  end
end

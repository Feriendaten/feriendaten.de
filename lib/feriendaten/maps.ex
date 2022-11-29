defmodule Feriendaten.Maps do
  @moduledoc """
  The Maps context.
  """

  import Ecto.Query, warn: false
  alias Feriendaten.Repo

  alias Feriendaten.Maps.Level

  @doc """
  Returns the list of levels.

  ## Examples

      iex> list_levels()
      [%Level{}, ...]

  """
  def list_levels do
    Repo.all(Level)
  end

  @doc """
  Gets a single level.

  Raises `Ecto.NoResultsError` if the Level does not exist.

  ## Examples

      iex> get_level!(123)
      %Level{}

      iex> get_level!(456)
      ** (Ecto.NoResultsError)

  """
  def get_level!(id), do: Repo.get!(Level, id)

  @doc """
  Gets a single level by name.

  Raises `Ecto.NoResultsError` if the Level does not exist.

  ## Examples

      iex> get_level_by_name!("Land")
      %Level{}

      iex> get_level_by_name!("humbug")
      ** (Ecto.NoResultsError)

  """
  def get_level_by_name!(name) do
    Repo.one(from l in Level, where: l.name == ^name)
  end

  @doc """
  Creates a level.

  ## Examples

      iex> create_level(%{field: value})
      {:ok, %Level{}}

      iex> create_level(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_level(attrs \\ %{}) do
    %Level{}
    |> Level.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a level.

  ## Examples

      iex> update_level(level, %{field: new_value})
      {:ok, %Level{}}

      iex> update_level(level, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_level(%Level{} = level, attrs) do
    level
    |> Level.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a level.

  ## Examples

      iex> delete_level(level)
      {:ok, %Level{}}

      iex> delete_level(level)
      {:error, %Ecto.Changeset{}}

  """
  def delete_level(%Level{} = level) do
    Repo.delete(level)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking level changes.

  ## Examples

      iex> change_level(level)
      %Ecto.Changeset{data: %Level{}}

  """
  def change_level(%Level{} = level, attrs \\ %{}) do
    Level.changeset(level, attrs)
  end

  alias Feriendaten.Maps.Location

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations do
    Repo.all(Location)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Gets a single location by slug.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location_by_slug!("koblenz")
      %Location{}

      iex> get_location_by_slug!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location_by_slug!(slug) do
    Repo.one(from l in Location, where: l.slug == ^slug)
  end

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  @doc """
  Returns a list of all parent_ids of a location.

  ## Examples

      iex> koblenz = get_location!(325)
      iex> recursive_parent_ids(koblenz)
      [325, 12, 1]

  """
  def recursive_parent_ids(%Location{} = location) do
    query =
      "WITH RECURSIVE cte_location AS(SELECT id,parent_id FROM locations WHERE id=" <>
        Integer.to_string(location.id) <>
        " UNION ALL SELECT e.id,e.parent_id FROM locations e INNER JOIN cte_location o ON o.parent_id=e.id)SELECT*FROM cte_location;"

    result = Ecto.Adapters.SQL.query!(Repo, query, [])

    result.rows
    |> Enum.map(fn [id, _] -> id end)
  end

  @doc """
  Sets is_active to TRUE for this location and all the parent locations.

  ## Examples

      iex> koblenz = get_location!(325)
      iex> activate_location_recursively(koblenz)

  """
  def activate_location_recursively(%Location{} = location) do
    ids = recursive_parent_ids(location)

    Repo.update_all(
      from(l in Location,
        where: l.id in ^ids
      ),
      set: [is_active: true]
    )
  end

  @doc """
  Lists all locations from a level with a given name.

  ## Examples

      iex> list_locations_by_level_name("Bundesland")
      [%Location{}, ...]

  """
  # Find Level by name and return all locations which belong to this level
  def list_locations_by_level_name(name) do
    Repo.all(
      from l in Location,
        join: lv in Level,
        on: l.level_id == lv.id,
        where: lv.name == ^name,
        where: l.is_active == true,
        order_by: [asc: l.name]
    )
  end
end

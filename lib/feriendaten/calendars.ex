defmodule Feriendaten.Calendars do
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
end

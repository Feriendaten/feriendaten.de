defmodule Feriendaten.CalendarsFixtures do
  import Feriendaten.MapsFixtures

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feriendaten.Calendars` context.
  """

  @doc """
  Generate a unique vacation colloquial.
  """
  def unique_vacation_colloquial, do: "some colloquial#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique vacation name.
  """
  def unique_vacation_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a vacation.
  """
  def vacation_fixture(attrs \\ %{}) do
    {:ok, vacation} =
      attrs
      |> Enum.into(%{
        colloquial: unique_vacation_colloquial(),
        for_everybody: true,
        for_students: true,
        legacy_id: 42,
        listed: true,
        name: unique_vacation_name(),
        priority: 42,
        public_holiday: true,
        school_vacation: true,
        wikipedia_url: "https://en.wikipedia.org/wiki/Some_wikipedia_url"
      })
      |> Feriendaten.Calendars.create_vacation()

    vacation
  end

  @doc """
  Generate a entry.
  """
  def entry_fixture(attrs \\ %{}) do
    location = location_fixture()
    vacation = vacation_fixture()

    {:ok, entry} =
      attrs
      |> Enum.into(%{
        location_id: location.id,
        vacation_id: vacation.id,
        ends_on: ~D[2022-11-19],
        for_everybody: true,
        for_students: true,
        legacy_id: 42,
        listed: true,
        memo: "some memo",
        public_holiday: true,
        school_vacation: true,
        starts_on: ~D[2022-11-19]
      })
      |> Feriendaten.Calendars.create_entry()

    entry
  end
end

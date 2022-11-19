defmodule Feriendaten.MapsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Feriendaten.Maps` context.
  """

  @doc """
  Generate a unique level name.
  """
  def unique_level_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique level order.
  """
  def unique_level_order, do: System.unique_integer([:positive])

  @doc """
  Generate a level.
  """
  def level_fixture(attrs \\ %{}) do
    {:ok, level} =
      attrs
      |> Enum.into(%{
        name: unique_level_name(),
        order: unique_level_order()
      })
      |> Feriendaten.Maps.create_level()

    level
  end

  @doc """
  Generate a unique location legacy_id.
  """
  def unique_location_legacy_id, do: System.unique_integer([:positive])

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        code: "some code",
        is_active: true,
        legacy_id: unique_location_legacy_id(),
        legacy_name: "some legacy name",
        legacy_parent_id: 42,
        legacy_slug: "some-legacy-slug",
        name: "some name",
        level_id: level_fixture().id
      })
      |> Feriendaten.Maps.create_location()

    location
  end
end

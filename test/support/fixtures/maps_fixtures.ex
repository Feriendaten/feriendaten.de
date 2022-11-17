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
  Generate a unique level slug.
  """
  def unique_level_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a level.
  """
  def level_fixture(attrs \\ %{}) do
    {:ok, level} =
      attrs
      |> Enum.into(%{
        name: unique_level_name(),
        order: unique_level_order(),
        slug: unique_level_slug()
      })
      |> Feriendaten.Maps.create_level()

    level
  end
end

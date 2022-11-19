defmodule Feriendaten.MapsTest do
  use Feriendaten.DataCase

  alias Feriendaten.Maps

  describe "levels" do
    alias Feriendaten.Maps.Level

    import Feriendaten.MapsFixtures

    @invalid_attrs %{name: nil, order: nil, slug: nil}

    test "list_levels/0 returns all levels" do
      level = level_fixture()
      assert Maps.list_levels() == [level]
    end

    test "get_level!/1 returns the level with given id" do
      level = level_fixture()
      assert Maps.get_level!(level.id) == level
    end

    test "create_level/1 with valid data creates a level" do
      valid_attrs = %{name: "some name", order: 42}

      assert {:ok, %Level{} = level} = Maps.create_level(valid_attrs)
      assert level.name == "some name"
      assert level.order == 42
      assert level.slug == "some-name"
    end

    test "create_level/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Maps.create_level(@invalid_attrs)
    end

    test "update_level/2 with valid data updates the level" do
      level = level_fixture()
      update_attrs = %{name: "some updated name", order: 43}

      assert {:ok, %Level{} = level} = Maps.update_level(level, update_attrs)
      assert level.name == "some updated name"
      assert level.order == 43
    end

    test "update_level/2 with invalid data returns error changeset" do
      level = level_fixture()
      assert {:error, %Ecto.Changeset{}} = Maps.update_level(level, @invalid_attrs)
      assert level == Maps.get_level!(level.id)
    end

    test "delete_level/1 deletes the level" do
      level = level_fixture()
      assert {:ok, %Level{}} = Maps.delete_level(level)
      assert_raise Ecto.NoResultsError, fn -> Maps.get_level!(level.id) end
    end

    test "change_level/1 returns a level changeset" do
      level = level_fixture()
      assert %Ecto.Changeset{} = Maps.change_level(level)
    end
  end

  describe "locations" do
    alias Feriendaten.Maps.Location

    import Feriendaten.MapsFixtures

    @invalid_attrs %{
      level_id: nil,
      name: nil
    }

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Maps.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Maps.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      level = level_fixture()

      valid_attrs = %{
        is_active: true,
        legacy_id: 42,
        legacy_name: "some legacy name",
        legacy_parent_id: 42,
        legacy_slug: "some-legacy-slug",
        name: "some name",
        level_id: level.id
      }

      assert {:ok, %Location{} = location} = Maps.create_location(valid_attrs)
      assert location.is_active == true
      assert location.legacy_id == 42
      assert location.legacy_name == "some legacy name"
      assert location.legacy_parent_id == 42
      assert location.legacy_slug == "some-legacy-slug"
      assert location.name == "some name"
      assert location.slug == "some-name"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Maps.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()

      update_attrs = %{
        code: "some updated code",
        is_active: false,
        legacy_id: 43,
        legacy_name: "some updated legacy_name",
        legacy_parent_id: 43,
        legacy_slug: "some updated legacy_slug",
        name: "some updated name"
      }

      assert {:ok, %Location{} = location} = Maps.update_location(location, update_attrs)
      assert location.code == "some updated code"
      assert location.is_active == false
      assert location.legacy_id == 43
      assert location.legacy_name == "some updated legacy_name"
      assert location.legacy_parent_id == 43
      assert location.legacy_slug == "some updated legacy_slug"
      assert location.name == "some updated name"
      assert location.slug == "some-name"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Maps.update_location(location, @invalid_attrs)
      assert location == Maps.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Maps.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Maps.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Maps.change_location(location)
    end
  end
end

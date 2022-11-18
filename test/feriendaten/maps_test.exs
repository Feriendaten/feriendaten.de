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
      assert level.slug == "some-updated-name"
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
end

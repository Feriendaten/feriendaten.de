defmodule Feriendaten.CalendarsTest do
  use Feriendaten.DataCase

  alias Feriendaten.Calendars

  import Feriendaten.CalendarsFixtures
  import Feriendaten.MapsFixtures

  describe "vacations" do
    alias Feriendaten.Calendars.Vacation

    import Feriendaten.CalendarsFixtures

    @invalid_attrs %{
      colloquial: nil,
      for_everybody: nil,
      for_students: nil,
      legacy_id: nil,
      listed: nil,
      name: nil,
      priority: nil,
      public_holiday: nil,
      school_vacation: nil,
      slug: nil,
      wikipedia_url: nil
    }

    test "list_vacations/0 returns all vacations" do
      vacation = vacation_fixture()
      assert Calendars.list_vacations() == [vacation]
    end

    test "get_vacation!/1 returns the vacation with given id" do
      vacation = vacation_fixture()
      assert Calendars.get_vacation!(vacation.id) == vacation
    end

    test "create_vacation/1 with valid data creates a vacation" do
      valid_attrs = %{
        colloquial: "some colloquial",
        for_everybody: true,
        for_students: true,
        legacy_id: 42,
        listed: true,
        name: "some name",
        priority: 42,
        public_holiday: true,
        school_vacation: true
      }

      assert {:ok, %Vacation{} = vacation} = Calendars.create_vacation(valid_attrs)
      assert vacation.colloquial == "some colloquial"
      assert vacation.for_everybody == true
      assert vacation.for_students == true
      assert vacation.legacy_id == 42
      assert vacation.listed == true
      assert vacation.name == "some name"
      assert vacation.priority == 42
      assert vacation.public_holiday == true
      assert vacation.school_vacation == true
      assert vacation.slug == "some-name"
    end

    test "create_vacation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendars.create_vacation(@invalid_attrs)
    end

    test "update_vacation/2 with valid data updates the vacation" do
      vacation = vacation_fixture()

      update_attrs = %{
        colloquial: "some updated colloquial",
        for_everybody: false,
        for_students: false,
        legacy_id: 43,
        listed: false,
        name: "some updated name",
        priority: 43,
        public_holiday: false,
        school_vacation: false
      }

      assert {:ok, %Vacation{} = vacation} = Calendars.update_vacation(vacation, update_attrs)
      assert vacation.colloquial == "some updated colloquial"
      assert vacation.for_everybody == false
      assert vacation.for_students == false
      assert vacation.legacy_id == 43
      assert vacation.listed == false
      assert vacation.name == "some updated name"
      assert vacation.priority == 43
      assert vacation.public_holiday == false
      assert vacation.school_vacation == false
    end

    test "update_vacation/2 with invalid data returns error changeset" do
      vacation = vacation_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendars.update_vacation(vacation, @invalid_attrs)
      assert vacation == Calendars.get_vacation!(vacation.id)
    end

    test "delete_vacation/1 deletes the vacation" do
      vacation = vacation_fixture()
      assert {:ok, %Vacation{}} = Calendars.delete_vacation(vacation)
      assert_raise Ecto.NoResultsError, fn -> Calendars.get_vacation!(vacation.id) end
    end

    test "change_vacation/1 returns a vacation changeset" do
      vacation = vacation_fixture()
      assert %Ecto.Changeset{} = Calendars.change_vacation(vacation)
    end
  end

  describe "entries" do
    alias Feriendaten.Calendars.Entry

    import Feriendaten.CalendarsFixtures

    @invalid_attrs %{
      ends_on: nil,
      for_everybody: nil,
      for_students: nil,
      legacy_id: nil,
      listed: nil,
      memo: nil,
      public_holiday: nil,
      school_vacation: nil,
      starts_on: nil
    }

    test "list_entries/0 returns all entries" do
      entry = entry_fixture()
      assert Calendars.list_entries() == [entry]
    end

    test "get_entry!/1 returns the entry with given id" do
      entry = entry_fixture()
      assert Calendars.get_entry!(entry.id) == entry
    end

    test "create_entry/1 with valid data creates a entry" do
      location = location_fixture()
      vacation = vacation_fixture()

      valid_attrs = %{
        ends_on: ~D[2022-11-19],
        for_everybody: true,
        for_students: true,
        legacy_id: 42,
        listed: true,
        memo: "some memo",
        public_holiday: true,
        school_vacation: true,
        starts_on: ~D[2022-11-19],
        location_id: location.id,
        vacation_id: vacation.id
      }

      assert {:ok, %Entry{} = entry} = Calendars.create_entry(valid_attrs)
      assert entry.ends_on == ~D[2022-11-19]
      assert entry.for_everybody == true
      assert entry.for_students == true
      assert entry.legacy_id == 42
      assert entry.listed == true
      assert entry.memo == "some memo"
      assert entry.public_holiday == true
      assert entry.school_vacation == true
      assert entry.starts_on == ~D[2022-11-19]
    end

    test "create_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendars.create_entry(@invalid_attrs)
    end

    test "update_entry/2 with valid data updates the entry" do
      entry = entry_fixture()

      update_attrs = %{
        ends_on: ~D[2022-11-20],
        for_everybody: false,
        for_students: false,
        legacy_id: 43,
        listed: false,
        memo: "some updated memo",
        public_holiday: false,
        school_vacation: false,
        starts_on: ~D[2022-11-20]
      }

      assert {:ok, %Entry{} = entry} = Calendars.update_entry(entry, update_attrs)
      assert entry.ends_on == ~D[2022-11-20]
      assert entry.for_everybody == false
      assert entry.for_students == false
      assert entry.legacy_id == 43
      assert entry.listed == false
      assert entry.memo == "some updated memo"
      assert entry.public_holiday == false
      assert entry.school_vacation == false
      assert entry.starts_on == ~D[2022-11-20]
    end

    test "update_entry/2 with invalid data returns error changeset" do
      entry = entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendars.update_entry(entry, @invalid_attrs)
      assert entry == Calendars.get_entry!(entry.id)
    end

    test "delete_entry/1 deletes the entry" do
      entry = entry_fixture()
      assert {:ok, %Entry{}} = Calendars.delete_entry(entry)
      assert_raise Ecto.NoResultsError, fn -> Calendars.get_entry!(entry.id) end
    end

    test "change_entry/1 returns a entry changeset" do
      entry = entry_fixture()
      assert %Ecto.Changeset{} = Calendars.change_entry(entry)
    end
  end
end

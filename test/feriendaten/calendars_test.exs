defmodule Feriendaten.CalendarsTest do
  use Feriendaten.DataCase

  alias Feriendaten.Calendars

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
end

defmodule FeriendatenWeb.Admin.EntryControllerTest do
  use FeriendatenWeb.ConnCase

  import Feriendaten.CalendarsFixtures
  import Feriendaten.MapsFixtures

  @create_attrs %{
    ends_on: ~D[2022-11-19],
    for_everybody: true,
    for_students: true,
    legacy_id: 42,
    listed: true,
    memo: "some memo",
    public_holiday: true,
    school_vacation: true,
    starts_on: ~D[2022-11-19]
  }
  @update_attrs %{
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
  @invalid_attrs %{
    ends_on: nil,
    for_everybody: nil,
    for_students: nil,
    legacy_id: nil,
    listed: nil,
    public_holiday: nil,
    school_vacation: nil,
    starts_on: nil
  }

  describe "index" do
    test "lists all entries", %{conn: conn} do
      conn = get(conn, ~p"/admin/entries")
      assert html_response(conn, 200) =~ "Listing Entries"
    end
  end

  describe "new entry" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/entries/new")
      assert html_response(conn, 200) =~ "New Entry"
    end
  end

  describe "create entry" do
    test "redirects to show when data is valid", %{conn: conn} do
      vacation = vacation_fixture()
      location = location_fixture()

      create_attrs =
        Map.merge(@create_attrs, %{
          vacation_id: vacation.id,
          location_id: location.id
        })

      conn = post(conn, ~p"/admin/entries", entry: create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/entries/#{id}"

      conn = get(conn, ~p"/admin/entries/#{id}")
      assert html_response(conn, 200) =~ "Entry #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/entries", entry: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Entry"
    end
  end

  describe "edit entry" do
    setup [:create_entry]

    test "renders form for editing chosen entry", %{conn: conn, entry: entry} do
      conn = get(conn, ~p"/admin/entries/#{entry}/edit")
      assert html_response(conn, 200) =~ "Edit Entry"
    end
  end

  describe "update entry" do
    setup [:create_entry]

    test "redirects when data is valid", %{conn: conn, entry: entry} do
      conn = put(conn, ~p"/admin/entries/#{entry}", entry: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/entries/#{entry}"

      conn = get(conn, ~p"/admin/entries/#{entry}")
      assert html_response(conn, 200) =~ "some updated memo"
    end

    test "renders errors when data is invalid", %{conn: conn, entry: entry} do
      conn = put(conn, ~p"/admin/entries/#{entry}", entry: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Entry"
    end
  end

  describe "delete entry" do
    setup [:create_entry]

    test "deletes chosen entry", %{conn: conn, entry: entry} do
      conn = delete(conn, ~p"/admin/entries/#{entry}")
      assert redirected_to(conn) == ~p"/admin/entries"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/entries/#{entry}")
      end
    end
  end

  defp create_entry(_) do
    location = location_fixture()
    vacation = vacation_fixture()
    entry = entry_fixture(%{location_id: location.id, vacation_id: vacation.id})
    %{entry: entry}
  end
end

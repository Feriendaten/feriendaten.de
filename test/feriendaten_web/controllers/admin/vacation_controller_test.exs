defmodule FeriendatenWeb.Admin.VacationControllerTest do
  use FeriendatenWeb.ConnCase

  import Feriendaten.CalendarsFixtures

  @create_attrs %{colloquial: "some colloquial", for_everybody: true, for_students: true, legacy_id: 42, listed: true, name: "some name", priority: 42, public_holiday: true, school_vacation: true, slug: "some slug", wikipedia_url: "some wikipedia_url"}
  @update_attrs %{colloquial: "some updated colloquial", for_everybody: false, for_students: false, legacy_id: 43, listed: false, name: "some updated name", priority: 43, public_holiday: false, school_vacation: false, slug: "some updated slug", wikipedia_url: "some updated wikipedia_url"}
  @invalid_attrs %{colloquial: nil, for_everybody: nil, for_students: nil, legacy_id: nil, listed: nil, name: nil, priority: nil, public_holiday: nil, school_vacation: nil, slug: nil, wikipedia_url: nil}

  describe "index" do
    test "lists all vacations", %{conn: conn} do
      conn = get(conn, ~p"/admin/vacations")
      assert html_response(conn, 200) =~ "Listing Vacations"
    end
  end

  describe "new vacation" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/vacations/new")
      assert html_response(conn, 200) =~ "New Vacation"
    end
  end

  describe "create vacation" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/vacations", vacation: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/vacations/#{id}"

      conn = get(conn, ~p"/admin/vacations/#{id}")
      assert html_response(conn, 200) =~ "Vacation #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/vacations", vacation: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Vacation"
    end
  end

  describe "edit vacation" do
    setup [:create_vacation]

    test "renders form for editing chosen vacation", %{conn: conn, vacation: vacation} do
      conn = get(conn, ~p"/admin/vacations/#{vacation}/edit")
      assert html_response(conn, 200) =~ "Edit Vacation"
    end
  end

  describe "update vacation" do
    setup [:create_vacation]

    test "redirects when data is valid", %{conn: conn, vacation: vacation} do
      conn = put(conn, ~p"/admin/vacations/#{vacation}", vacation: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/vacations/#{vacation}"

      conn = get(conn, ~p"/admin/vacations/#{vacation}")
      assert html_response(conn, 200) =~ "some updated colloquial"
    end

    test "renders errors when data is invalid", %{conn: conn, vacation: vacation} do
      conn = put(conn, ~p"/admin/vacations/#{vacation}", vacation: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Vacation"
    end
  end

  describe "delete vacation" do
    setup [:create_vacation]

    test "deletes chosen vacation", %{conn: conn, vacation: vacation} do
      conn = delete(conn, ~p"/admin/vacations/#{vacation}")
      assert redirected_to(conn) == ~p"/admin/vacations"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/vacations/#{vacation}")
      end
    end
  end

  defp create_vacation(_) do
    vacation = vacation_fixture()
    %{vacation: vacation}
  end
end

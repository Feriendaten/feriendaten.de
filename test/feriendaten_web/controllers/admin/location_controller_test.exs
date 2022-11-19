defmodule FeriendatenWeb.Admin.LocationControllerTest do
  use FeriendatenWeb.ConnCase

  import Feriendaten.MapsFixtures

  @create_attrs %{
    is_active: true,
    legacy_id: 42,
    legacy_name: "some legacy name",
    legacy_parent_id: 42,
    legacy_slug: "some-legacy-slug",
    name: "some name"
  }
  @update_attrs %{
    code: "some updated code",
    is_active: false,
    legacy_id: 43,
    legacy_name: "some updated legacy_name",
    legacy_parent_id: 43,
    name: "some updated name"
  }
  @invalid_attrs %{name: nil, level_id: nil}

  describe "index" do
    test "lists all locations", %{conn: conn} do
      conn = get(conn, ~p"/admin/locations")
      assert html_response(conn, 200) =~ "Listing Locations"
    end
  end

  describe "new location" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/locations/new")
      assert html_response(conn, 200) =~ "New Location"
    end
  end

  describe "create location" do
    test "redirects to show when data is valid", %{conn: conn} do
      level = level_fixture()

      conn =
        post(conn, ~p"/admin/locations", location: Map.put(@create_attrs, :level_id, level.id))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/locations/#{id}"

      conn = get(conn, ~p"/admin/locations/#{id}")
      assert html_response(conn, 200) =~ "Location #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/locations", location: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Location"
    end
  end

  describe "edit location" do
    setup [:create_location]

    test "renders form for editing chosen location", %{conn: conn, location: location} do
      conn = get(conn, ~p"/admin/locations/#{location}/edit")
      assert html_response(conn, 200) =~ "Edit Location"
    end
  end

  describe "update location" do
    setup [:create_location]

    test "redirects when data is valid", %{conn: conn, location: location} do
      conn = put(conn, ~p"/admin/locations/#{location}", location: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/locations/#{location}"

      conn = get(conn, ~p"/admin/locations/#{location}")
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, location: location} do
      conn = put(conn, ~p"/admin/locations/#{location}", location: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Location"
    end
  end

  describe "delete location" do
    setup [:create_location]

    test "deletes chosen location", %{conn: conn, location: location} do
      conn = delete(conn, ~p"/admin/locations/#{location}")
      assert redirected_to(conn) == ~p"/admin/locations"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/locations/#{location}")
      end
    end
  end

  defp create_location(_) do
    location = location_fixture()
    %{location: location}
  end
end

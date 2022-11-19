defmodule FeriendatenWeb.Admin.AddressControllerTest do
  use FeriendatenWeb.ConnCase

  import Feriendaten.SchoolsFixtures

  @create_attrs %{
    city: "some city",
    email: "some email",
    fax: "some fax",
    lat: 120.5,
    legacy_id: 42,
    line1: "some line1",
    lon: 120.5,
    phone: "some phone",
    school_type: "some school_type",
    street: "some street",
    url: "some url",
    zip_code: "some zip_code"
  }
  @update_attrs %{
    city: "some updated city",
    email: "some updated email",
    fax: "some updated fax",
    lat: 456.7,
    legacy_id: 43,
    line1: "some updated line1",
    lon: 456.7,
    phone: "some updated phone",
    school_type: "some updated school_type",
    street: "some updated street",
    url: "some updated url",
    zip_code: "some updated zip_code"
  }
  @invalid_attrs %{
    city: nil,
    email: nil,
    fax: nil,
    lat: nil,
    legacy_id: nil,
    line1: nil,
    lon: nil,
    phone: nil,
    school_type: nil,
    street: nil,
    url: nil,
    zip_code: nil
  }

  describe "index" do
    test "lists all addresses", %{conn: conn} do
      conn = get(conn, ~p"/admin/addresses")
      assert html_response(conn, 200) =~ "Listing Addresses"
    end
  end

  describe "new address" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/addresses/new")
      assert html_response(conn, 200) =~ "New Address"
    end
  end

  describe "create address" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/addresses", address: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/addresses/#{id}"

      conn = get(conn, ~p"/admin/addresses/#{id}")
      assert html_response(conn, 200) =~ "Address #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/addresses", address: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Address"
    end
  end

  describe "edit address" do
    setup [:create_address]

    test "renders form for editing chosen address", %{conn: conn, address: address} do
      conn = get(conn, ~p"/admin/addresses/#{address}/edit")
      assert html_response(conn, 200) =~ "Edit Address"
    end
  end

  describe "update address" do
    setup [:create_address]

    test "redirects when data is valid", %{conn: conn, address: address} do
      conn = put(conn, ~p"/admin/addresses/#{address}", address: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/addresses/#{address}"

      conn = get(conn, ~p"/admin/addresses/#{address}")
      assert html_response(conn, 200) =~ "some updated city"
    end

    test "renders errors when data is invalid", %{conn: conn, address: address} do
      conn = put(conn, ~p"/admin/addresses/#{address}", address: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Address"
    end
  end

  describe "delete address" do
    setup [:create_address]

    test "deletes chosen address", %{conn: conn, address: address} do
      conn = delete(conn, ~p"/admin/addresses/#{address}")
      assert redirected_to(conn) == ~p"/admin/addresses"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/addresses/#{address}")
      end
    end
  end

  defp create_address(_) do
    address = address_fixture()
    %{address: address}
  end
end

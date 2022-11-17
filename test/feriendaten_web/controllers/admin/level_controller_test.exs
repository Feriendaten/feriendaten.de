defmodule FeriendatenWeb.Admin.LevelControllerTest do
  use FeriendatenWeb.ConnCase

  import Feriendaten.MapsFixtures

  @create_attrs %{name: "some name", order: 42, slug: "some slug"}
  @update_attrs %{name: "some updated name", order: 43, slug: "some updated slug"}
  @invalid_attrs %{name: nil, order: nil, slug: nil}

  describe "index" do
    test "lists all levels", %{conn: conn} do
      conn = get(conn, ~p"/admin/levels")
      assert html_response(conn, 200) =~ "Listing Levels"
    end
  end

  describe "new level" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/levels/new")
      assert html_response(conn, 200) =~ "New Level"
    end
  end

  describe "create level" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/levels", level: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/levels/#{id}"

      conn = get(conn, ~p"/admin/levels/#{id}")
      assert html_response(conn, 200) =~ "Level #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/levels", level: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Level"
    end
  end

  describe "edit level" do
    setup [:create_level]

    test "renders form for editing chosen level", %{conn: conn, level: level} do
      conn = get(conn, ~p"/admin/levels/#{level}/edit")
      assert html_response(conn, 200) =~ "Edit Level"
    end
  end

  describe "update level" do
    setup [:create_level]

    test "redirects when data is valid", %{conn: conn, level: level} do
      conn = put(conn, ~p"/admin/levels/#{level}", level: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/levels/#{level}"

      conn = get(conn, ~p"/admin/levels/#{level}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, level: level} do
      conn = put(conn, ~p"/admin/levels/#{level}", level: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Level"
    end
  end

  describe "delete level" do
    setup [:create_level]

    test "deletes chosen level", %{conn: conn, level: level} do
      conn = delete(conn, ~p"/admin/levels/#{level}")
      assert redirected_to(conn) == ~p"/admin/levels"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/levels/#{level}")
      end
    end
  end

  defp create_level(_) do
    level = level_fixture()
    %{level: level}
  end
end

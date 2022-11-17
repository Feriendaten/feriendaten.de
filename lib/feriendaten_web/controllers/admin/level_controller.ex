defmodule FeriendatenWeb.Admin.LevelController do
  use FeriendatenWeb, :controller

  alias Feriendaten.Maps
  alias Feriendaten.Maps.Level

  def index(conn, _params) do
    levels = Maps.list_levels()
    render(conn, :index, levels: levels)
  end

  def new(conn, _params) do
    changeset = Maps.change_level(%Level{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"level" => level_params}) do
    case Maps.create_level(level_params) do
      {:ok, level} ->
        conn
        |> put_flash(:info, "Level created successfully.")
        |> redirect(to: ~p"/admin/levels/#{level}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    level = Maps.get_level!(id)
    render(conn, :show, level: level)
  end

  def edit(conn, %{"id" => id}) do
    level = Maps.get_level!(id)
    changeset = Maps.change_level(level)
    render(conn, :edit, level: level, changeset: changeset)
  end

  def update(conn, %{"id" => id, "level" => level_params}) do
    level = Maps.get_level!(id)

    case Maps.update_level(level, level_params) do
      {:ok, level} ->
        conn
        |> put_flash(:info, "Level updated successfully.")
        |> redirect(to: ~p"/admin/levels/#{level}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, level: level, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    level = Maps.get_level!(id)
    {:ok, _level} = Maps.delete_level(level)

    conn
    |> put_flash(:info, "Level deleted successfully.")
    |> redirect(to: ~p"/admin/levels")
  end
end

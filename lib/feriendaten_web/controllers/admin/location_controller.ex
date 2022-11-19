defmodule FeriendatenWeb.Admin.LocationController do
  use FeriendatenWeb, :controller

  alias Feriendaten.Maps
  alias Feriendaten.Maps.Location

  def index(conn, _params) do
    locations = Maps.list_locations()
    render(conn, :index, locations: locations)
  end

  def new(conn, _params) do
    changeset = Maps.change_location(%Location{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"location" => location_params}) do
    case Maps.create_location(location_params) do
      {:ok, location} ->
        conn
        |> put_flash(:info, "Location created successfully.")
        |> redirect(to: ~p"/admin/locations/#{location}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    location = Maps.get_location!(id)
    render(conn, :show, location: location)
  end

  def edit(conn, %{"id" => id}) do
    location = Maps.get_location!(id)
    changeset = Maps.change_location(location)
    render(conn, :edit, location: location, changeset: changeset)
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location = Maps.get_location!(id)

    case Maps.update_location(location, location_params) do
      {:ok, location} ->
        conn
        |> put_flash(:info, "Location updated successfully.")
        |> redirect(to: ~p"/admin/locations/#{location}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, location: location, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    location = Maps.get_location!(id)
    {:ok, _location} = Maps.delete_location(location)

    conn
    |> put_flash(:info, "Location deleted successfully.")
    |> redirect(to: ~p"/admin/locations")
  end
end

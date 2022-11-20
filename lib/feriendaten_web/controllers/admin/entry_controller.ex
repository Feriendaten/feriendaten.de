defmodule FeriendatenWeb.Admin.EntryController do
  use FeriendatenWeb, :controller

  alias Feriendaten.Calendars
  alias Feriendaten.Calendars.Entry

  def index(conn, _params) do
    entries = Calendars.list_entries()
    render(conn, :index, entries: entries)
  end

  def new(conn, _params) do
    changeset = Calendars.change_entry(%Entry{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"entry" => entry_params}) do
    case Calendars.create_entry(entry_params) do
      {:ok, entry} ->
        conn
        |> put_flash(:info, "Entry created successfully.")
        |> redirect(to: ~p"/admin/entries/#{entry}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    entry = Calendars.get_entry!(id)
    render(conn, :show, entry: entry)
  end

  def edit(conn, %{"id" => id}) do
    entry = Calendars.get_entry!(id)
    changeset = Calendars.change_entry(entry)
    render(conn, :edit, entry: entry, changeset: changeset)
  end

  def update(conn, %{"id" => id, "entry" => entry_params}) do
    entry = Calendars.get_entry!(id)

    case Calendars.update_entry(entry, entry_params) do
      {:ok, entry} ->
        conn
        |> put_flash(:info, "Entry updated successfully.")
        |> redirect(to: ~p"/admin/entries/#{entry}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, entry: entry, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    entry = Calendars.get_entry!(id)
    {:ok, _entry} = Calendars.delete_entry(entry)

    conn
    |> put_flash(:info, "Entry deleted successfully.")
    |> redirect(to: ~p"/admin/entries")
  end
end

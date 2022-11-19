defmodule FeriendatenWeb.Admin.VacationController do
  use FeriendatenWeb, :controller

  alias Feriendaten.Calendars
  alias Feriendaten.Calendars.Vacation

  def index(conn, _params) do
    vacations = Calendars.list_vacations()
    render(conn, :index, vacations: vacations)
  end

  def new(conn, _params) do
    changeset = Calendars.change_vacation(%Vacation{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"vacation" => vacation_params}) do
    case Calendars.create_vacation(vacation_params) do
      {:ok, vacation} ->
        conn
        |> put_flash(:info, "Vacation created successfully.")
        |> redirect(to: ~p"/admin/vacations/#{vacation}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    vacation = Calendars.get_vacation!(id)
    render(conn, :show, vacation: vacation)
  end

  def edit(conn, %{"id" => id}) do
    vacation = Calendars.get_vacation!(id)
    changeset = Calendars.change_vacation(vacation)
    render(conn, :edit, vacation: vacation, changeset: changeset)
  end

  def update(conn, %{"id" => id, "vacation" => vacation_params}) do
    vacation = Calendars.get_vacation!(id)

    case Calendars.update_vacation(vacation, vacation_params) do
      {:ok, vacation} ->
        conn
        |> put_flash(:info, "Vacation updated successfully.")
        |> redirect(to: ~p"/admin/vacations/#{vacation}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, vacation: vacation, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    vacation = Calendars.get_vacation!(id)
    {:ok, _vacation} = Calendars.delete_vacation(vacation)

    conn
    |> put_flash(:info, "Vacation deleted successfully.")
    |> redirect(to: ~p"/admin/vacations")
  end
end

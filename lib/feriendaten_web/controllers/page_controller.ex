defmodule FeriendatenWeb.PageController do
  use FeriendatenWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def index(conn, _params) do
    locations = Feriendaten.Maps.list_locations_by_level_name("Bundesland")

    conn
    |> put_root_layout(:ferien)
    |> assign(:year, nil)
    |> assign(:location, nil)
    |> assign(:locations, locations)
    |> render(:index, page_title: "Ferien")
  end

  def datenschutzerklaerung(conn, _params) do
    conn
    |> assign(:location, nil)
    |> assign(:entries, nil)
    |> assign(:end_date, nil)
    |> assign(:year, nil)
    |> put_root_layout(:ferien)
    |> render(:datenschutzerklaerung)
  end
end

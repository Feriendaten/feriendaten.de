defmodule FeriendatenWeb.PageController do
  use FeriendatenWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def index(conn, _params) do
    locations = Feriendaten.Maps.list_locations_by_level_name("Bundesland")
    render(conn, :index, locations: locations)
  end
end

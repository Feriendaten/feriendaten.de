defmodule FeriendatenWeb.Plugs.SetDates do
  import Plug.Conn

  def init(default), do: default

  def call(%Plug.Conn{params: %{"datum" => datum}} = conn, _default) do
    {date, noindex} =
      case Date.from_iso8601(datum) do
        {:ok, date} ->
          {date, true}

        _ ->
          {Date.utc_today(), false}
      end

    today = Date.utc_today()

    conn
    |> assign(:noindex, noindex)
    |> assign(:requested_date, date)
    |> assign(:today, today)
  end

  def call(conn, _default) do
    today = Date.utc_today()

    conn
    |> assign(:noindex, false)
    |> assign(:requested_date, today)
    |> assign(:today, today)
  end
end

defmodule FeriendatenWeb.Plugs.SetToday do
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

    conn
    |> assign(:noindex, noindex)
    |> assign(:today, date)
  end

  def call(conn, _default) do
    date = Date.utc_today()

    conn
    |> assign(:noindex, false)
    |> assign(:today, date)
  end
end

defmodule Mix.Tasks.UpdateUrlsToHttps do
  @moduledoc "Import legacy data"
  use Mix.Task
  import Ecto.Query

  alias Feriendaten.{Repo, Schools.Address}

  @requirements ["app.start"]

  @shortdoc "Check if urls are https and update them if not and if 200."
  def run(_) do
    update_url_to_https()
  end

  defp update_url_to_https do
    query = from(a in Address)
    addresses = Repo.all(query) |> Enum.filter(&(&1.url != nil))

    Enum.each(addresses, fn a ->
      https_url = String.replace(a.url, "http://", "https://")
      %URI{path: path, scheme: scheme, host: host} = URI.parse(https_url)

      if a.url != https_url do
        https_url = String.trim(https_url)

        https_url =
          if Enum.member?(
               ["/", nil, "/index.html", "/index.htm", "/home.html", "/startseite.html"],
               path
             ) do
            "#{scheme}://#{host}"
          else
            https_url
          end

        case HTTPoison.get(https_url) do
          {:error, _} ->
            nil

          {:ok, response_https} ->
            if response_https.status_code == 200 do
              a
              |> Address.changeset(%{url: https_url})
              |> Repo.update()
            else
              nil
            end

          _ ->
            nil
        end
      end
    end)
  end
end

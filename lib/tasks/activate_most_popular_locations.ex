defmodule Mix.Tasks.ActivateMostPopularLocations do
  @moduledoc "Analyse GA data"
  use Mix.Task
  import Ecto.Query

  alias Feriendaten.Repo
  alias Feriendaten.Maps.Location

  @requirements ["app.start"]

  @shortdoc "Analyse GA data. Activate most popular 10,000 locations."
  def run(_) do
    File.stream!("priv/ga-data.csv")
    |> CSV.decode()
    |> Enum.to_list()
    |> Enum.each(fn line ->
      case line do
        {:ok, [url, _, _]} ->
          parts =
            String.split(url, "/")
            |> Enum.reject(fn x ->
              Enum.member?(
                ["", "ferien", "d", "bundesland", "stadt", "schule", "schulbeginn"],
                x
              )
            end)

          # Iterate over the parts and query them brute force for the
          # location slug.
          #
          Enum.each(parts, fn part ->
            query = from(l in Location, where: l.legacy_slug == ^part, limit: 1)

            case Repo.one(query) do
              %Location{} = location ->
                Feriendaten.Maps.activate_location_recursively(location)

              _ ->
                nil
            end
          end)

        _ ->
          nil
      end
    end)
  end
end

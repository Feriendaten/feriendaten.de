defmodule Mix.Tasks.BugFixForLegacyImport do
  @moduledoc "Import legacy data"
  use Mix.Task
  import Ecto.Query

  alias Feriendaten.{Repo, LegacyRepo, Legacy, Maps.Location, Schools.Address}

  @requirements ["app.start"]

  @shortdoc "Fix Imported legacy data (missing location_id)."
  def run(_) do
    fix_addresses()
  end

  defp fix_addresses do
    query = from(a in Legacy.Address)
    addresses = LegacyRepo.all(query)

    Enum.each(addresses, fn a ->
      query = from(l in Location, where: l.legacy_id == ^a.school_location_id, limit: 1)
      location = Repo.one(query)

      query =
        from(address in Address,
          where: address.line1 == ^location.name,
          where: address.zip_code == ^a.zip_code,
          where: address.legacy_id == ^a.id,
          limit: 1
        )

      address = Repo.one(query)

      address
      |> Address.changeset(%{location_id: location.id})
      |> Repo.update()
    end)
  end
end

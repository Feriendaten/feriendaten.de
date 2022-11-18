defmodule Mix.Tasks.LegacyImport do
  @moduledoc "Import legacy data"
  use Mix.Task
  import Ecto.Query

  alias Feriendaten.LegacyRepo
  alias Feriendaten.Maps

  @requirements ["app.start"]

  @shortdoc "Import legacy data."
  def run(_) do
    create_levels()
  end

  defp create_levels do
    {:ok, _land} =
      Maps.create_level(%{
        name: "Land",
        order: 1
      })

    {:ok, _bundesland} =
      Maps.create_level(%{
        name: "Bundesland",
        order: 2
      })

    {:ok, _kreis} =
      Maps.create_level(%{
        name: "Landkreis",
        order: 3
      })

    {:ok, _stadt} =
      Maps.create_level(%{
        name: "Stadt",
        order: 4
      })

    {:ok, _schule} =
      Maps.create_level(%{
        name: "Schule",
        order: 5
      })
  end
end

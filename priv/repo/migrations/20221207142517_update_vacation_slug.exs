defmodule Feriendaten.Repo.Migrations.UpdateVacationSlug do
  use Ecto.Migration

  alias Feriendaten.Calendars.Vacation
  alias Feriendaten.EctoSlug.ColloquialSlug
  alias Feriendaten.Repo

  # Loop through all vacations and upcase the name
  #
  def up do
    Feriendaten.Repo.all(Feriendaten.Calendars.Vacation)
    |> Enum.each(fn vacation ->
      vacation
      |> Vacation.changeset(%{})
      |> ColloquialSlug.maybe_generate_slug()
      |> Repo.update!()
    end)
  end
end

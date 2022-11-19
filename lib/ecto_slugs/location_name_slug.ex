defmodule Feriendaten.EctoSlug.LocationNameSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug

  import Ecto.Query
  alias Feriendaten.Repo
  alias Feriendaten.Maps.Location

  def build_slug(sources, changeset) do
    # See docs:
    # https://hexdocs.pm/ecto_autoslug_field/EctoAutoslugField.SlugBase.html#build_slug/1
    # => will receive default slug: my-todo
    slug =
      super(sources, changeset)
      |> String.replace(~r/[^a-z0-9\-]/i, "", global: true)
      |> String.replace("--", "-", global: true)
      |> String.trim()

    if slug_already_exists?(slug) do
      slug <> "-" <> Integer.to_string(available_number(slug, changeset))
    else
      slug
    end
  end

  defp available_number(slug, changeset, counter \\ 2) do
    next_slug = slug <> "-" <> Integer.to_string(counter)

    if slug_already_exists?(next_slug) do
      available_number(slug, changeset, counter + 1)
    else
      counter
    end
  end

  defp slug_already_exists?(slug) do
    query = from(l in Location, where: l.slug == ^slug, limit: 1)
    Repo.one(query) != nil
  end
end

defmodule Feriendaten.Maps.Location do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feriendaten.EctoSlug.LocationNameSlug

  schema "locations" do
    field :code, :string
    field :is_active, :boolean, default: false
    field :legacy_id, :integer
    field :legacy_name, :string
    field :legacy_parent_id, :integer
    field :legacy_slug, :string
    field :name, :string
    field :slug, LocationNameSlug.Type
    field :parent_id, :id
    field :level_id, :id

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [
      :name,
      :code,
      :legacy_id,
      :legacy_name,
      :legacy_parent_id,
      :legacy_slug,
      :is_active,
      :parent_id,
      :level_id
    ])
    |> validate_required([
      :name,
      :level_id
    ])
    |> LocationNameSlug.maybe_generate_slug()
    |> LocationNameSlug.unique_constraint()
  end
end

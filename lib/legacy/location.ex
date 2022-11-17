defmodule Feriendaten.Legacy.Location do
  use Ecto.Schema

  schema "locations" do
    field :is_city, :boolean, default: false
    field :is_country, :boolean, default: false
    field :is_county, :boolean, default: false
    field :is_federal_state, :boolean, default: false
    field :is_school, :boolean, default: false
    field :name, :string
    field :code, :string
    field :slug, :string

    belongs_to :parent_location, __MODULE__

    timestamps()
  end
end

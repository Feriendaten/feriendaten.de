defmodule Feriendaten.Maps.Level do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feriendaten.EctoSlug.NameSlug

  schema "levels" do
    field :name, :string
    field :order, :integer
    field :slug, NameSlug.Type

    timestamps()
  end

  @doc false
  def changeset(level, attrs) do
    level
    |> cast(attrs, [:name, :order])
    |> validate_required([:name, :order])
    |> unique_constraint(:order)
    |> unique_constraint(:name)
    |> NameSlug.maybe_generate_slug()
    |> NameSlug.unique_constraint()
  end
end

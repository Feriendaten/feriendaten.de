defmodule Feriendaten.Maps.Level do
  use Ecto.Schema
  import Ecto.Changeset

  schema "levels" do
    field :name, :string
    field :order, :integer
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(level, attrs) do
    level
    |> cast(attrs, [:name, :order, :slug])
    |> validate_required([:name, :order, :slug])
    |> unique_constraint(:slug)
    |> unique_constraint(:order)
    |> unique_constraint(:name)
  end
end

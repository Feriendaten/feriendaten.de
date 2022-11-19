defmodule Feriendaten.Calendars.Vacation do
  use Ecto.Schema
  import Ecto.Changeset
  alias Feriendaten.EctoSlug.NameSlug

  schema "vacations" do
    field :colloquial, :string
    field :for_everybody, :boolean, default: false
    field :for_students, :boolean, default: false
    field :legacy_id, :integer
    field :listed, :boolean, default: false
    field :name, :string
    field :priority, :integer
    field :public_holiday, :boolean, default: false
    field :school_vacation, :boolean, default: false
    field :slug, NameSlug.Type
    field :wikipedia_url, :string

    timestamps()
  end

  @doc false
  def changeset(vacation, attrs) do
    vacation
    |> cast(attrs, [
      :name,
      :colloquial,
      :for_everybody,
      :for_students,
      :public_holiday,
      :school_vacation,
      :listed,
      :priority,
      :wikipedia_url,
      :legacy_id
    ])
    |> validate_required([
      :name
    ])
    |> unique_constraint(:colloquial)
    |> unique_constraint(:name)
    |> NameSlug.maybe_generate_slug()
    |> NameSlug.unique_constraint()
  end
end

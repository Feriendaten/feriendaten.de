defmodule Feriendaten.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :code, :string
      add :legacy_id, :integer
      add :legacy_name, :string
      add :legacy_parent_id, :integer
      add :legacy_slug, :string
      add :is_active, :boolean, default: false, null: false
      add :slug, :string
      add :parent_id, references(:locations, on_delete: :nothing)
      add :level_id, references(:levels, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:locations, [:slug])
    create unique_index(:locations, [:legacy_id])
    create index(:locations, [:parent_id])
    create index(:locations, [:level_id])
  end
end

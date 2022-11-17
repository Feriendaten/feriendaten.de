defmodule Feriendaten.Repo.Migrations.CreateLevels do
  use Ecto.Migration

  def change do
    create table(:levels) do
      add :name, :string
      add :order, :integer
      add :slug, :string

      timestamps()
    end

    create unique_index(:levels, [:slug])
    create unique_index(:levels, [:order])
    create unique_index(:levels, [:name])
  end
end

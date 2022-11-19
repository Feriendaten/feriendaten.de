defmodule Feriendaten.Repo.Migrations.CreateVacations do
  use Ecto.Migration

  def change do
    create table(:vacations) do
      add :name, :string
      add :colloquial, :string
      add :for_everybody, :boolean, default: false, null: false
      add :for_students, :boolean, default: false, null: false
      add :public_holiday, :boolean, default: false, null: false
      add :school_vacation, :boolean, default: false, null: false
      add :listed, :boolean, default: false, null: false
      add :priority, :integer
      add :slug, :string
      add :wikipedia_url, :string
      add :legacy_id, :integer

      timestamps()
    end

    create unique_index(:vacations, [:slug])
    create unique_index(:vacations, [:colloquial])
    create unique_index(:vacations, [:name])
  end
end

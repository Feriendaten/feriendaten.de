defmodule Feriendaten.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :starts_on, :date
      add :ends_on, :date
      add :for_everybody, :boolean, default: false, null: false
      add :for_students, :boolean, default: false, null: false
      add :public_holiday, :boolean, default: false, null: false
      add :school_vacation, :boolean, default: false, null: false
      add :listed, :boolean, default: false, null: false
      add :memo, :text
      add :legacy_id, :integer
      add :vacation_id, references(:vacations, on_delete: :nothing)
      add :location_id, references(:locations, on_delete: :nothing)

      timestamps()
    end

    create index(:entries, [:vacation_id])
    create index(:entries, [:location_id])
  end
end

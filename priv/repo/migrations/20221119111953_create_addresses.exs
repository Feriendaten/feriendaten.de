defmodule Feriendaten.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :city, :string
      add :email, :string
      add :fax, :string
      add :lat, :float
      add :lon, :float
      add :legacy_id, :integer
      add :line1, :string
      add :phone, :string
      add :school_type, :string
      add :street, :string
      add :url, :string
      add :zip_code, :string
      add :location_id, references(:locations, on_delete: :nothing)

      timestamps()
    end

    create index(:addresses, [:location_id])
  end
end

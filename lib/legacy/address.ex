defmodule Feriendaten.Legacy.Address do
  use Ecto.Schema

  schema "addresses" do
    field :line1, :string
    field :street, :string
    field :zip_code, :string
    field :city, :string
    field :email_address, :string
    field :phone_number, :string
    field :fax_number, :string
    field :homepage_url, :string
    field :school_type, :string
    field :official_id, :string
    field :lon, :float
    field :lat, :float
    field :school_location_id, :integer

    timestamps()
  end
end

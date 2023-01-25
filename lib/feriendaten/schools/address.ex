defmodule Feriendaten.Schools.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :city, :string
    field :email, :string
    field :fax, :string
    field :lat, :float
    field :legacy_id, :integer
    field :line1, :string
    field :lon, :float
    field :phone, :string
    field :school_type, :string
    field :street, :string
    field :url, :string
    field :zip_code, :string
    field :location_id, :id

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [
      :city,
      :email,
      :fax,
      :lat,
      :lon,
      :legacy_id,
      :line1,
      :phone,
      :school_type,
      :street,
      :url,
      :zip_code,
      :location_id
    ])
    |> validate_required([:city, :line1, :zip_code])
  end
end

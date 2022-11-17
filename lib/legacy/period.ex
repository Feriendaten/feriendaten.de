defmodule Feriendaten.Legacy.Period do
  use Ecto.Schema

  schema "periods" do
    field :created_by_email_address, :string
    field :ends_on, :date
    field :html_class, :string
    field :is_listed_below_month, :boolean, default: false
    field :is_public_holiday, :boolean, default: false
    field :is_school_vacation, :boolean, default: false
    field :is_valid_for_everybody, :boolean, default: false
    field :is_valid_for_students, :boolean, default: false
    field :starts_on, :date
    field :memo, :string
    field :display_priority, :integer
    field :location_id, :integer
    field :holiday_or_vacation_type_id, :integer
    field :religion_id, :integer

    timestamps()
  end
end

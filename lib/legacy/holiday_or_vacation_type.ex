defmodule Feriendaten.Legacy.HolidayOrVacationType do
  use Ecto.Schema

  schema "holiday_or_vacation_types" do
    field :colloquial, :string
    field :default_html_class, :string
    field :default_is_listed_below_month, :boolean, default: false
    field :default_is_public_holiday, :boolean, default: false
    field :default_is_school_vacation, :boolean, default: false
    field :default_is_valid_for_everybody, :boolean, default: false
    field :default_is_valid_for_students, :boolean, default: false
    field :name, :string
    field :slug, :string
    field :wikipedia_url, :string
    field :default_display_priority, :integer

    has_many :periods, Feriendaten.Legacy.Period, on_delete: :delete_all

    timestamps()
  end
end

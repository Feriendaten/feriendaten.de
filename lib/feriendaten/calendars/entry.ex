defmodule Feriendaten.Calendars.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :ends_on, :date
    field :for_everybody, :boolean, default: false
    field :for_students, :boolean, default: false
    field :legacy_id, :integer
    field :listed, :boolean, default: false
    field :memo, :string
    field :public_holiday, :boolean, default: false
    field :school_vacation, :boolean, default: false
    field :starts_on, :date
    field :vacation_id, :id
    field :location_id, :id

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [
      :starts_on,
      :ends_on,
      :for_everybody,
      :for_students,
      :public_holiday,
      :school_vacation,
      :listed,
      :memo,
      :legacy_id,
      :location_id,
      :vacation_id
    ])
    |> validate_required([
      :starts_on,
      :ends_on,
      :for_everybody,
      :for_students,
      :public_holiday,
      :school_vacation,
      :listed,
      :location_id,
      :vacation_id
    ])
  end
end

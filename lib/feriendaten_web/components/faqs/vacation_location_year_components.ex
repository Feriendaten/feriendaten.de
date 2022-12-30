defmodule FeriendatenWeb.VacationLocationYearComponents do
  @moduledoc """
  Provides VacationLocation FAQ components for the FeriendatenWeb application.
  """
  use FeriendatenWeb, :html

  # /osterferien/hessen/2023
  attr :entries, :list, required: true
  attr :location, :string, required: true
  attr :requested_date, :any, required: true
  attr :vacation_slug, :string, required: true

  def vacation_location_faq(assigns) do
    vacation_colloquial = extract_vacation_colloquial(assigns.entries)
    preposition = preposition(assigns.location.name)
    first_entry = first_entry(assigns.entries, vacation_colloquial)
    year = first_entry.starts_on.year

    assigns =
      assigns
      |> assign(:vacation_colloquial, vacation_colloquial)
      |> assign(:first_entry, first_entry)
      |> assign(:preposition, preposition)
      |> assign(:year, year)

    ~H"""
    <div class="col-span-3">
      <h2 class="pt-4 mb-8 text-2xl font-semibold tracking-tight text-gray-900 dark:text-white">
        FAQ
      </h2>

      <p class="mb-8 text-base tracking-tight text-gray-900 dark:text-white">
        Nachfolgend finden Sie typische Suchmaschinen Anfragen zu diesem Thema.
      </p>

      <div
        class="grid grid-cols-1 gap-4 md:grid-cols-2"
        itemscope=""
        itemtype="https://schema.org/FAQPage"
      >
        <.generic_wann_sind_x_ferien_in
          frage={"Wann sind #{@vacation_colloquial} #{@preposition} #{@location.name} #{@year}?"}
          entries={@entries}
          location={@location}
          requested_date={@requested_date}
          vacation_slug={@vacation_slug}
        />

        <.generic_wann_sind_x_ferien_in
          frage={"Wann beginnen die #{@vacation_colloquial} #{@preposition} #{@location.name} #{@year}?"}
          entries={@entries}
          location={@location}
          requested_date={@requested_date}
          vacation_slug={@vacation_slug}
        />

        <.generic_wann_sind_x_ferien_in
          frage={"Wann sind #{@vacation_colloquial} #{@year} #{@location.name} ?"}
          entries={@entries}
          location={@location}
          requested_date={@requested_date}
          vacation_slug={@vacation_slug}
        />

        <.wie_lange_sind_x_ferien_in_location
          entries={@entries}
          location={@location}
          requested_date={@requested_date}
          vacation_slug={@vacation_slug}
          year={@year}
        />

        <.wann_ist_der_letzte_schultag_vor_den_x_ferien_location
          entries={@entries}
          location={@location}
          requested_date={@requested_date}
          vacation_slug={@vacation_slug}
          year={@year}
        />

        <.warum_kurz
          entries={@entries}
          location={@location}
          requested_date={@requested_date}
          vacation_slug={@vacation_slug}
          year={@year}
        />
      </div>
    </div>
    """
  end

  def warum_kurz(assigns) do
    vacation_colloquial = extract_vacation_colloquial(assigns.entries)
    first_entry = first_entry(assigns.entries, vacation_colloquial)

    assigns =
      assigns
      |> assign(:vacation_colloquial, vacation_colloquial)
      |> assign(:first_entry, first_entry)

    if Enum.member?(["Herbstferien", "Osterferien"], vacation_colloquial) && first_entry.days < 8 &&
         length(assigns.entries) == 1 do
      ~H"""
      <div itemscope="" itemprop="mainEntity" itemtype="https://schema.org/Question">
        <h3 class="flex items-center mb-4 text-lg font-medium text-gray-900 dark:text-white">
          <div itemprop="name">
            Warum sind die <%= @vacation_colloquial %> <%= @location.name %> <%= @first_entry.starts_on.year %> so kurz?
          </div>
        </h3>
        <div itemscope="" itemprop="acceptedAnswer" itemtype="https://schema.org/Answer">
          <p class="text-gray-500 dark:text-gray-400" itemprop="text">
            Je nachdem wie die Sommerferien terminlich fallen, werden die <%= @vacation_colloquial %> in <%= @location.name %> gekürzt. Wenn die Sommerferien eher spät sind, dann werden die Herbstferien verkürzt und dafür die Osterferien verlängert. Sind die Sommerferien eher früh, dann werden die Herbstferien verlängert und die Osterferien verkürzt.
          </p>
        </div>
      </div>
      """
    else
      ~H"""

      """
    end
  end

  def generic_wann_sind_x_ferien_in(assigns) do
    vacation_colloquial = extract_vacation_colloquial(assigns.entries)
    first_entry = first_entry(assigns.entries, vacation_colloquial)

    assigns =
      assigns
      |> assign(:vacation_colloquial, vacation_colloquial)
      |> assign(:first_entry, first_entry)

    if Enum.member?([:gt, :eq], Date.compare(assigns.requested_date, first_entry.starts_on)) &&
         Enum.member?([:lt, :eq], Date.compare(assigns.requested_date, first_entry.ends_on)) do
      ~H"""
      <div itemscope="" itemprop="mainEntity" itemtype="https://schema.org/Question">
        <h3 class="flex items-center mb-4 text-lg font-medium text-gray-900 dark:text-white">
          <div itemprop="name">
            <%= @frage %>
          </div>
        </h3>
        <div itemscope="" itemprop="acceptedAnswer" itemtype="https://schema.org/Answer">
          <p class="text-gray-500 dark:text-gray-400" itemprop="text">
            Gerade sind die <%= @vacation_colloquial %> <%= @location.name %> <%= @first_entry.starts_on.year %>.
            Sie starteten am <%= Calendar.strftime(@first_entry.starts_on, "%d.%m.%y") %> (<%= FeriendatenWeb.LocationYearFaqComponents.wochentag(
              @first_entry.starts_on
            ) %>) und enden am <%= Calendar.strftime(
              @first_entry.ends_on,
              "%d.%m.%y"
            ) %> (<%= FeriendatenWeb.LocationYearFaqComponents.wochentag(@first_entry.ends_on) %>).
          </p>
        </div>
      </div>
      """
    else
      ~H"""
      <div itemscope="" itemprop="mainEntity" itemtype="https://schema.org/Question">
        <h3 class="flex items-center mb-4 text-lg font-medium text-gray-900 dark:text-white">
          <div itemprop="name">
            <%= @frage %>
          </div>
        </h3>
        <div itemscope="" itemprop="acceptedAnswer" itemtype="https://schema.org/Answer">
          <p class="text-gray-500 dark:text-gray-400" itemprop="text">
            <%= if Date.diff(@first_entry.starts_on, assigns.requested_date) == 1 do %>
              Morgen
            <% else %>
              In <%= Date.diff(@first_entry.starts_on, assigns.requested_date) %> Tagen
            <% end %>
            beginnen die <%= @vacation_colloquial %> <%= @location.name %> <%= @first_entry.starts_on.year %>.
            Sie starten am <%= Calendar.strftime(@first_entry.starts_on, "%d.%m.%y") %> (<%= FeriendatenWeb.LocationYearFaqComponents.wochentag(
              @first_entry.starts_on
            ) %>) und enden am <%= Calendar.strftime(
              @first_entry.ends_on,
              "%d.%m.%y"
            ) %> (<%= FeriendatenWeb.LocationYearFaqComponents.wochentag(@first_entry.ends_on) %>).
          </p>
        </div>
      </div>
      """
    end
  end

  def wie_lange_sind_x_ferien_in_location(assigns) do
    vacation_colloquial = extract_vacation_colloquial(assigns.entries)
    preposition = preposition(assigns.location.name)
    first_entry = first_entry(assigns.entries, vacation_colloquial)

    assigns =
      assigns
      |> assign(:vacation_colloquial, vacation_colloquial)
      |> assign(:first_entry, first_entry)
      |> assign(:preposition, preposition)

    ~H"""
    <div itemscope="" itemprop="mainEntity" itemtype="https://schema.org/Question">
      <h3 class="flex items-center mb-4 text-lg font-medium text-gray-900 dark:text-white">
        <div itemprop="name">
          Wie lange sind die <%= @vacation_colloquial %> <%= @year %> <%= @preposition %> <%= @location.name %>?
        </div>
      </h3>
      <div itemscope="" itemprop="acceptedAnswer" itemtype="https://schema.org/Answer">
        <p class="text-gray-500 dark:text-gray-400" itemprop="text">
          Die <%= @vacation_colloquial %> <%= @location.name %> <%= @first_entry.starts_on.year %> dauern <%= Date.diff(
            @first_entry.ends_on,
            @first_entry.starts_on
          ) + 1 %> Tage.
          Sie beginnen am <%= Calendar.strftime(@first_entry.starts_on, "%d.%m.%y") %> (<%= FeriendatenWeb.LocationYearFaqComponents.wochentag(
            @first_entry.starts_on
          ) %>) und enden am <%= Calendar.strftime(
            @first_entry.ends_on,
            "%d.%m.%y"
          ) %> (<%= FeriendatenWeb.LocationYearFaqComponents.wochentag(@first_entry.ends_on) %>).
        </p>
      </div>
    </div>
    """
  end

  def wann_ist_der_letzte_schultag_vor_den_x_ferien_location(assigns) do
    vacation_colloquial = extract_vacation_colloquial(assigns.entries)
    first_entry = first_entry(assigns.entries, vacation_colloquial)

    last_school_day =
      case FeriendatenWeb.LocationYearFaqComponents.wochentag(first_entry.starts_on) do
        "Montag" -> Date.add(first_entry.starts_on, -3)
        "Sonntag" -> Date.add(first_entry.starts_on, -2)
        "Samstag" -> Date.add(first_entry.starts_on, -1)
        _ -> Date.add(first_entry.starts_on, -1)
      end

    assigns =
      assigns
      |> assign(:vacation_colloquial, vacation_colloquial)
      |> assign(:first_entry, first_entry)
      |> assign(:last_school_day, last_school_day)

    ~H"""
    <div itemscope="" itemprop="mainEntity" itemtype="https://schema.org/Question">
      <h3 class="flex items-center mb-4 text-lg font-medium text-gray-900 dark:text-white">
        <div itemprop="name">
          Wann ist der letzte Schultag vor den <%= @vacation_colloquial %> <%= @year %> <%= @location.name %>?
        </div>
      </h3>
      <div itemscope="" itemprop="acceptedAnswer" itemtype="https://schema.org/Answer">
        <p class="text-gray-500 dark:text-gray-400" itemprop="text">
          Die <%= @vacation_colloquial %> <%= @location.name %> <%= @first_entry.starts_on.year %> beginnen am <%= Calendar.strftime(
            @first_entry.starts_on,
            "%d.%m.%y"
          ) %> (<%= FeriendatenWeb.LocationYearFaqComponents.wochentag(@first_entry.starts_on) %>). Der letzte Schultag ist <%= FeriendatenWeb.LocationYearFaqComponents.wochentag(
            @last_school_day
          ) %> der <%= Calendar.strftime(
            @last_school_day,
            "%d.%m.%y"
          ) %>.
        </p>
      </div>
    </div>
    """
  end

  defp extract_vacation_colloquial(entries) do
    hd(entries) |> Map.get(:colloquial)
  end

  defp preposition(location_name) do
    case location_name do
      "Saarland" -> "im"
      _ -> "in"
    end
  end

  defp first_entry(entries, vacation_colloquial) do
    Enum.find(entries, fn entry -> entry.colloquial == vacation_colloquial end)
  end
end

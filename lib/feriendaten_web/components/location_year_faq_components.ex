defmodule FeriendatenWeb.LocationYearFaqComponents do
  @moduledoc """
  Provides FAQ components for the FeriendatenWeb application.
  """
  use FeriendatenWeb, :html

  attr :location, :string, required: true
  attr :entries, :list, required: true
  attr :requested_date, :any, required: true
  attr :year, :integer, required: true

  def location_year_faq(assigns) do
    ~H"""
    <!-- FAQ -->
    <div class="bg-white dark:bg-gray-900">
      <div class="py-16 mx-auto lg:py-20">
        <div class="lg:grid lg:grid-cols-3 lg:gap-8">
          <div>
            <h2 class="text-3xl font-bold tracking-tight text-gray-900 dark:text-gray-100">
              FAQ
            </h2>
            <p class="mt-4 text-lg text-gray-500">
              Antworten auf die in Suchmaschinen am häufigsten gestellten Fragen zum Thema Schulferien in <%= @location.name %> im Jahr <%= @year %>.
            </p>
          </div>
          <div class="mt-12 lg:col-span-2 lg:mt-0">
            <dl class="space-y-12">
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Wann sind Ferien in <%= @location.name %> <%= @year %>?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  <.answer_wann_sind_ferien_in
                    location={@location}
                    entries={@entries}
                    requested_date={@requested_date}
                    year={@year}
                  />
                </dd>
              </div>
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Hat <%= @location.name %> Ferien <%= @year %>?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  <.answer_wann_sind_ferien_in
                    location={@location}
                    entries={@entries}
                    requested_date={@requested_date}
                    year={@year}
                  />
                </dd>
              </div>
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Wann Ferien in <%= @location.code %> <%= @year %>?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  <.answer_wann_sind_ferien_in
                    location={@location}
                    entries={@entries}
                    requested_date={@requested_date}
                    year={@year}
                  />
                </dd>
              </div>
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Wie viele Ferientage hat <%= @location.code %> <%= @year %>?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  Insgesamt gibt es in <%= @location.name %> <%= sum_of_days(@entries, @year) %> Ferientage im Jahr <%= @year %>.
                </dd>
              </div>
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Wie viele Tage Ferien hat <%= @location.name %> <%= @year %>?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  Insgesamt gibt es in <%= @location.name %> <%= sum_of_days(@entries, @year) %> Ferientage im Jahr <%= @year %>.
                </dd>
              </div>
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Wann gibt es Zeugnisse in <%= @location.name %> <%= @year %>?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  <.zeugnisausgabetermin location={@location} entries={@entries} />
                </dd>
              </div>
            </dl>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :location, :string, required: true
  attr :entries, :list, required: true
  attr :requested_date, :any, required: true
  attr :year, :integer, required: true

  defp answer_wann_sind_ferien_in(assigns) do
    ~H"""
    <% [first_entry | other_entries] = @entries %>
    <%= if first_entry.colloquial == "Weihnachtsferien" do %>
      Das Jahr <%= @year %> startet mit den <%= first_entry.colloquial %> des Vorjahres (<%= first_entry.ferientermin %>). Danach folgen die Ferientermine für 2022:
      <%= for entry <- other_entries do %>
        <%= entry.colloquial %> (<%= entry.ferientermin %>)
        <%= if entry != Enum.at(other_entries, -1) do %>
          <%= if entry == Enum.at(other_entries, -2) do %>
            und
          <% else %>
            ,
          <% end %>
        <% else %>
          .
        <% end %>
      <% end %>
    <% else %>
      <%= for entry <- @entries do %>
        <%= entry.colloquial %> (<%= entry.ferientermin %>)
        <%= if entry != Enum.at(other_entries, -1) do %>
          <%= if entry == Enum.at(other_entries, -2) do %>
            und
          <% else %>
            ,
          <% end %>
        <% else %>
          .
        <% end %>
      <% end %>
    <% end %>
    """
  end

  attr :location, :string, required: true
  attr :entries, :list, required: true

  defp zeugnisausgabetermin(assigns) do
    ~H"""
    <% ausgabetag = ausgabetag(@entries) %>
    <%= unless ausgabetag == nil do %>
      Die Zeugnisse in <%= @location.name %> werden am <%= Calendar.strftime(
        ausgabetag,
        "%d.%m.%Y"
      ) %> (<%= wochentag(ausgabetag) %>) ausgeteilt. Abschlussklassen bekommen die Zeugnisse früher.
    <% else %>
      Dazu gibt es leider gerade keine Information in unserem System.
    <% end %>
    """
  end

  defp sum_of_days(entries, year) do
    entries
    |> Enum.map(fn entry -> days_in_year(entry, year) end)
    |> Enum.sum()
  end

  defp days_in_year(%{starts_on: starts_on, ends_on: ends_on} = entry, year) do
    year_as_integer = String.to_integer(year)

    case [starts_on.year, ends_on.year] do
      [^year_as_integer, ^year_as_integer] ->
        entry.days

      [^year_as_integer, _] ->
        Date.diff(Date.from_iso8601!(year <> "-12-31"), starts_on) + 1

      [_, ^year_as_integer] ->
        Date.diff(ends_on, Date.from_iso8601!(year <> "-01-01")) + 1

      [_, _] ->
        0
    end
  end

  defp wochentag(date) do
    case Date.day_of_week(date) do
      1 -> "Montag"
      2 -> "Dienstag"
      3 -> "Mittwoch"
      4 -> "Donnerstag"
      5 -> "Freitag"
      6 -> "Samstag"
      7 -> "Sonntag"
    end
  end

  defp ausgabetag(entries) do
    case Enum.filter(entries, fn x -> x.colloquial == "Sommerferien" end) do
      [entry] ->
        case Date.day_of_week(Date.add(entry.starts_on, -1)) do
          7 -> Date.add(entry.starts_on, -3)
          6 -> Date.add(entry.starts_on, -2)
          _ -> Date.add(entry.starts_on, -1)
        end

      _ ->
        nil
    end
  end
end

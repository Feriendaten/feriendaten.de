defmodule FeriendatenWeb.LocationFaqComponents do
  @moduledoc """
  Provides FAQ components for the FeriendatenWeb application.
  """
  use FeriendatenWeb, :html

  attr :location, :string, required: true
  attr :entries, :list, required: true
  attr :requested_date, :any, required: true

  def location_faq(assigns) do
    ~H"""
    <div class="bg-white dark:bg-gray-900">
      <div class="py-16 mx-auto lg:py-20">
        <div class="lg:grid lg:grid-cols-3 lg:gap-8">
          <div>
            <h2 class="text-3xl font-bold tracking-tight text-gray-900 dark:text-gray-100">
              FAQ
            </h2>
            <p class="mt-4 text-lg text-gray-500">
              Antworten auf die in Suchmaschinen am häufigsten gestellten Fragen zum Thema Schulferien in <%= @location.name %>.
            </p>
          </div>
          <div class="mt-12 lg:col-span-2 lg:mt-0">
            <dl class="space-y-12">
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Wann sind Ferien in <%= @location.name %>?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  <.answer_wann_sind_ferien_in
                    location={@location}
                    entries={@entries}
                    requested_date={@requested_date}
                  />
                </dd>
              </div>
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Wann Ferien in <%= @location.code %>?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  <.answer_wann_sind_ferien_in
                    location={@location}
                    entries={@entries}
                    requested_date={@requested_date}
                  />
                </dd>
              </div>
              <div>
                <dt class="text-lg font-medium leading-6 text-gray-900 dark:text-gray-100">
                  Wann fangen in <%= @location.name %> die Ferien an?
                </dt>
                <dd class="mt-2 text-base text-gray-500">
                  <.answer_wann_sind_ferien_in
                    location={@location}
                    entries={@entries}
                    requested_date={@requested_date}
                  />
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

  defp answer_wann_sind_ferien_in(assigns) do
    ~H"""
    <% [first_entry | other_entries] = @entries %>
    <%= if Date.compare(first_entry.starts_on, @requested_date) == :lt  do %>
      Aktuell sind <%= first_entry.colloquial %> (<%= first_entry.ferientermin %>).
    <% else %>
      In <%= Date.diff(first_entry.starts_on, @requested_date) %> Tagen beginnen die <%= first_entry.colloquial %> (<%= first_entry.ferientermin %>).
    <% end %>
    Später folgen die
    <%= for entry <- other_entries do %>
      <%= "#{entry.colloquial} (#{entry.ferientermin})" %>
      <%= if entry != Enum.at(other_entries, -1) do %>
        <%= if entry == Enum.at(other_entries, -2), do: "und", else: "," %>
      <% else %>
        .
      <% end %>
    <% end %>
    """
  end
end

defmodule FeriendatenWeb.FerienComponents do
  @moduledoc """
  Provides Ferien components for the FeriendatenWeb application.
  """
  use FeriendatenWeb, :html

  attr :entries, :list, required: true
  attr :dont_list_year, :integer, default: nil
  attr :is_school_year, :boolean, default: false

  def vacations_table(%{entries: []} = assigns) do
    ~H"""
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <p class="mt-2 text-gray-700 dark:text-gray-100">
          Für dieses Datum sind noch keine Termine in unserer Datenbank gespeichert.
        </p>
      </div>
    </div>
    """
  end

  def vacations_table(assigns) do
    ~H"""
    <div class="flex flex-col mt-8">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full align-middle">
          <div class="overflow-hidden shadow-sm ring-1 ring-black ring-opacity-5">
            <.vacations_table_table_only entries={@entries} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :entries, :list, required: true
  attr :dont_list_year, :integer, default: nil
  attr :is_school_year, :boolean, default: false

  def vacations_table_table_only(assigns) do
    # Check if this is two Weihnachtsferien. In that case just take the last one.
    assigns =
      if length(assigns.entries) == 2 &&
           Enum.at(assigns.entries, -1).colloquial == "Weihnachtsferien" &&
           Enum.at(assigns.entries, -2).colloquial == "Weihnachtsferien" do
        assign(assigns, :entries, [Enum.at(assigns.entries, -1)])
      else
        assigns
      end

    number_of_federal_states =
      assigns.entries |> Enum.map(fn x -> x.location_name end) |> Enum.uniq() |> length

    assigns =
      if number_of_federal_states > 1 do
        assign(assigns, :multi_locations, true)
      else
        assign(assigns, :multi_locations, false)
      end

    ~H"""
    <table class="min-w-full text-base divide-y divide-gray-300 table-auto dark:divide-gray-100">
      <thead class="bg-gray-100 dark:bg-gray-800">
        <tr>
          <th
            scope="col"
            class="py-2.5 pl-4 pr-3 text-left font-semibold text-gray-900 sm:pl-6 lg:pl-8 dark:text-zinc-100"
          >
            Ferien
          </th>

          <th scope="col" class="px-3 py-2.5 text-left font-semibold text-gray-900 dark:text-zinc-100">
            Zeitraum
          </th>
          <th
            scope="col"
            class="hidden px-3 py-2.5 text-left font-semibold text-gray-900 dark:text-zinc-100 xs:table-cell"
          >
            Dauer
          </th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-200 dark:bg-gray-900 dark:divide-gray-600">
        <%= for {entry, index} <- Enum.with_index(@entries) do %>
          <tr class={
            if rem(index, 2) == 0 do
              "bg-white dark:bg-black"
            else
              "bg-gray-50 dark:bg-black"
            end
          }>
            <td class="py-4 pl-4 pr-3 font-medium text-gray-900 align-top sm:pl-6 lg:pl-8 dark:text-gray-100">
              <%= if @multi_locations do %>
                <.link
                  class="text-blue-600 hover:underline dark:text-blue-400"
                  navigate={
                    ~p"/#{entry.vacation_slug}/#{entry.location_slug}/#{entry.starts_on.year}"
                  }
                >
                  <%= entry.colloquial %> <%= entry.location_name %> <%= entry.starts_on.year %>
                </.link>
              <% else %>
                <%= if @is_school_year do %>
                  <.link
                    class="text-blue-600 hover:underline dark:text-blue-400"
                    navigate={
                      ~p"/#{entry.vacation_slug}/#{entry.location_slug}/#{entry.starts_on.year}"
                    }
                  >
                    <%= entry.colloquial %> <%= entry.starts_on.year %>
                  </.link>
                <% else %>
                  <%= unless @dont_list_year == entry.starts_on.year do %>
                    <.link
                      class="text-blue-600 hover:underline dark:text-blue-400"
                      navigate={
                        ~p"/#{entry.vacation_slug}/#{entry.location_slug}/#{entry.starts_on.year}"
                      }
                    >
                      <%= entry.colloquial %> <%= entry.starts_on.year %>
                    </.link>
                  <% else %>
                    <.link
                      class="text-blue-600 hover:underline dark:text-blue-400"
                      navigate={~p"/#{entry.vacation_slug}/#{entry.location_slug}"}
                    >
                      <%= entry.colloquial %>
                    </.link>
                  <% end %>
                <% end %>
              <% end %>
            </td>

            <% termine = String.split(entry.ferientermin, ",") %>
            <td class="px-3 py-4 text-gray-900 align-top dark:text-gray-300 tabular-nums">
              <.link
                class="text-blue-600 hover:underline dark:text-blue-400"
                navigate={~p"/#{entry.vacation_slug}/#{entry.location_slug}/#{entry.starts_on.year}"}
              >
                <%= for termin <- termine do %>
                  <div class="whitespace-nowrap">
                    <%= termin %><%= if hd(Enum.take(termine, -2)) != termin &&
                                          List.last(termine) != termin,
                                        do: "," %>
                  </div>
                  <%= if length(termine) != 1 && hd(Enum.take(termine, -2)) == termin,
                    do: " und" %>
                <% end %>
              </.link>
            </td>
            <td class="hidden px-3 py-4 text-right text-gray-500 align-top whitespace-nowrap dark:text-gray-300 xs:table-cell tabular-nums">
              <%= entry.days %> Tag<%= unless entry.days == 1, do: "e" %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  attr :entries, :list, required: true
  attr :today, :any, required: true
  attr :requested_date, :any, required: true
  attr :end_date, :any, required: true

  defp pre_text_to_vacation_table(%{entries: []} = assigns) do
    ~H"""

    """
  end

  defp pre_text_to_vacation_table(assigns) do
    ~H"""
    <p class="mt-2 text-gray-700 dark:text-gray-100">
      Alle <%= Enum.count(@entries) %> Ferientermine <%= from(@today, @requested_date) %> bis <%= till(
        @end_date
      ) %>.
    </p>
    """
  end

  def from(today, requested_date) do
    if requested_date == today do
      "von heute"
    else
      "vom #{Calendar.strftime(requested_date, "%d.%m.%Y")}"
    end
  end

  def till(end_date) do
    if end_date.month >= 10 do
      "zum Jahresende #{end_date.year}"
    else
      if end_date.month <= 4 do
        "zum Jahresende #{end_date.year}"
      else
        "zu den Sommerferien #{end_date.year}"
      end
    end
  end

  attr :nav_bar_entries, :list, required: true

  def top_nav_bar(assigns) do
    ~H"""
    <nav
      class="flex text-sm bg-white border-b border-gray-200 dark:bg-gray-800 md:text-base"
      aria-label="Breadcrumb"
    >
      <ol
        role="list"
        class="flex w-full max-w-screen-xl px-4 mx-auto space-x-4 sm:px-6 lg:px-8"
        itemscope
        itemtype="https://schema.org/BreadcrumbList"
      >
        <li class="flex">
          <div class="flex items-center">
            <a
              href="/"
              class="text-gray-400 hover:text-gray-500 dark:text-zinc-100 dark:hover:text-gray-400"
            >
              <!-- Heroicon name: mini/home -->
              <svg
                class="flex-shrink-0 w-5 h-5"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M9.293 2.293a1 1 0 011.414 0l7 7A1 1 0 0117 11h-1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-3a1 1 0 00-1-1H9a1 1 0 00-1 1v3a1 1 0 01-1 1H5a1 1 0 01-1-1v-6H3a1 1 0 01-.707-1.707l7-7z"
                  clip-rule="evenodd"
                />
              </svg>
              <span class="sr-only">Hauptseite</span>
            </a>
          </div>
        </li>

        <%= for {entry, index} <- Enum.with_index(@nav_bar_entries) do %>
          <.top_nav_bar_item item={entry} index={index} />
        <% end %>
        <%= if @nav_bar_entries == [] do %>
          <.top_nav_bar_item item="" index={1} />
        <% end %>
      </ol>
    </nav>
    """
  end

  attr :item, :any, required: true
  attr :index, :integer, required: true

  defp top_nav_bar_item(%{item: [text, link]} = assigns) do
    assigns = assign(assigns, :text, text)
    assigns = assign(assigns, :link, link)

    ~H"""
    <li class="flex" itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem">
      <div class="flex items-center">
        <svg
          class="flex-shrink-0 w-6 h-full text-gray-200"
          viewBox="0 0 24 44"
          preserveAspectRatio="none"
          fill="currentColor"
          xmlns="http://www.w3.org/2000/svg"
          aria-hidden="true"
        >
          <path d="M.293 0l22 22-22 22h1.414l22-22-22-22H.293z" />
        </svg>
        <div class="ml-4 font-medium text-gray-500 dark:text-zinc-400">
          <%= if @link do %>
            <a itemprop="item" class="text-blue-600 hover:underline dark:text-blue-400" href={@link}>
              <span itemprop="name"><%= raw(hyphonate_string(@text)) %></span>
            </a>
          <% else %>
            <span itemprop="name"><%= raw(hyphonate_string(@text)) %></span>
          <% end %>
          <meta itemprop="position" content={@index + 1} />
        </div>
      </div>
    </li>
    """
  end

  defp top_nav_bar_item(%{item: text} = assigns) do
    assigns = assign(assigns, :item, [text, nil])

    top_nav_bar_item(assigns)
  end

  def hyphonate_string(string) do
    string
    |> String.replace("Weihnacht", "Weih&shy;nacht")
    |> String.replace("Mecklenburg", "Mecklen&shy;burg")
    |> String.replace("Vorpommern", "Vor&shy;pommern")
    |> String.replace("Nordrhein", "Nord&shy;rhein")
    |> String.replace("Westfalen", "West&shy;falen")
    |> String.replace("Rheinland", "Rhein&shy;land")
    |> String.replace("Schleswig", "Schles&shy;wig")
    |> String.replace("Weihnachtsferien", "Weih&shy;nachts&shy;ferien")
    |> String.replace("Winterferien", "Winter&shy;ferien")
    |> String.replace("Frühjahrsferien", "Früh&shy;jahrs&shy;ferien")
    |> String.replace("Osterferien", "Oster&shy;ferien")
    |> String.replace(
      "Himmelfahrt- und Pfingst­ferien",
      "Him&shy;mel&shy;­fahrt- und Pfingst&shy;­ferien"
    )
    |> String.replace(
      "Himmelfahrtsferien",
      "Him&shy;mel&shy;­fahrts&shy;­ferien"
    )
    |> String.replace("Pfingstferien", "Pfingst&shy;ferien")
    |> String.replace("Sommerferien", "Sommer&shy;ferien")
    |> String.replace("Herbstferien", "Herbst&shy;ferien")
    |> String.replace("Baden-Württemberg", "Ba&shy;den-Würt&shy;tem&shy;berg")
    |> String.replace("Brandenburg", "Bran&shy;den&shy;burg")
    |> String.replace("Mecklenburg-Vorpommern", "Meck&shy;len&shy;burg-Vor&shy;pom&shy;mern")
    |> String.replace("Niedersachsen", "Nie&shy;der&shy;sach&shy;sen")
    |> String.replace("Schles­wig-Holstein", "Schles&shy;wig-Hol&shy;stein")
    |> String.replace("Sachsen-Anhalt", "Sach&shy;sen-An&shy;halt")
    |> String.replace("Nord­rhein-West­falen", "Nord&shy;rhein-West&shy;fa&shy;len")
    |> String.replace("Rhein­land-Pfalz", "Rhein&shy;land-Pfalz")
  end
end

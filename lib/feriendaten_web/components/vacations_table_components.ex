defmodule FeriendatenWeb.VacationsTableComponents do
  @moduledoc """
  Provides Table components for the FeriendatenWeb application.
  """
  use FeriendatenWeb, :html

  attr :entries, :list, required: true

  def vacations_location_year_table(assigns) do
    ~H"""
    <table class="min-w-full text-base divide-y divide-gray-300 table-auto dark:divide-gray-100">
      <thead class="bg-gray-100 dark:bg-gray-800">
        <tr>
          <th scope="col" class="px-3 py-2.5 text-left font-semibold text-gray-900 dark:text-zinc-100">
            Ferien&shy;termin
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
            <% termine = String.split(entry.ferientermin, ",") %>
            <td class="px-3 py-4 text-gray-900 align-top dark:text-gray-300 tabular-nums">
              <%= for termin <- termine do %>
                <div class="whitespace-nowrap">
                  <%= termin %><%= if hd(Enum.take(termine, -2)) != termin &&
                                        List.last(termine) != termin,
                                      do: "," %>
                </div>
                <%= if length(termine) != 1 && hd(Enum.take(termine, -2)) == termin,
                  do: " und" %>
              <% end %>
            </td>
            <td class="hidden px-3 py-4 text-gray-500 align-top whitespace-nowrap dark:text-gray-300 xs:table-cell tabular-nums">
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
end

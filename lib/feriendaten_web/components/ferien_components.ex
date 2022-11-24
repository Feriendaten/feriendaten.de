defmodule FeriendatenWeb.FerienComponents do
  @moduledoc """
  Provides Ferien components for the FeriendatenWeb application.
  """
  use Phoenix.Component

  attr :entries, :list, required: true

  def vacations_table(assigns) do
    ~H"""
    <div class="flex flex-col mt-8">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full align-middle">
          <div class="overflow-hidden shadow-sm ring-1 ring-black ring-opacity-5">
            <table class="min-w-full divide-y divide-gray-300 table-auto dark:divide-gray-100">
              <thead class="bg-gray-100 dark:bg-gray-800">
                <tr>
                  <th
                    scope="col"
                    class="py-2.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6 lg:pl-8 dark:text-zinc-100"
                  >
                    Ferien
                  </th>
                  <th
                    scope="col"
                    class="px-3 py-2.5 text-left text-sm font-semibold text-gray-900 dark:text-zinc-100"
                  >
                    Zeitraum
                  </th>
                  <th
                    scope="col"
                    class="hidden px-3 py-2.5 text-left text-sm font-semibold text-gray-900 dark:text-zinc-100 xs:table-cell"
                  >
                    Dauer
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200 dark:bg-gray-900 dark:divide-gray-600">
                <%= for {period, index} <- Enum.with_index(@entries) do %>
                  <tr class={
                    if rem(index, 2) == 0 do
                      "bg-white dark:bg-black"
                    else
                      "bg-gray-50 dark:bg-black"
                    end
                  }>
                    <td class="py-4 pl-4 pr-3 text-sm font-medium text-gray-900 align-top sm:pl-6 lg:pl-8 dark:text-gray-100">
                      <%= period.colloquial %> <%= period.starts_on.year %>
                    </td>
                    <% termine = String.split(period.ferientermin, ",") %>
                    <td class="px-3 py-4 text-sm text-gray-900 align-top dark:text-gray-300 tabular-nums">
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
                    <td class="hidden px-3 py-4 text-sm text-right text-gray-500 align-top whitespace-nowrap dark:text-gray-300 xs:table-cell tabular-nums">
                      <%= period.days %> Tag<%= unless period.days == 1, do: "e" %>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end
end

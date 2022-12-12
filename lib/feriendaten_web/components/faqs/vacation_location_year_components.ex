defmodule FeriendatenWeb.VacationLocationYearComponents do
  @moduledoc """
  Provides VacationLocationYear FAQ components for the FeriendatenWeb application.
  """
  use FeriendatenWeb, :html

  alias FeriendatenWeb.FederalStateFaq

  # /osterferien/hessen/2023
  attr :entries, :list, required: true
  attr :location, :string, required: true
  attr :year, :string, required: true
  attr :requested_date, :any, required: true

  def vacation_location_year_faq(assigns) do
    assigns = enrich_with_faq_entries(assigns)

    unless assigns.faq_entries == [] do
      ~H"""
      <section class="bg-white dark:bg-gray-900">
        <div class="pt-8">
          <h2 class="mb-8 text-4xl font-extrabold tracking-tight text-gray-900 dark:text-white">
            FAQ
          </h2>
          <div class="grid pt-8 text-left border-t border-gray-200 md:gap-16 dark:border-gray-700 md:grid-cols-2">
            <%= for faq_entries <- [@first_half, @second_half] do %>
              <div>
                <%= for faq_entry <- faq_entries do %>
                  <div class="mb-10">
                    <h3 class="flex items-center mb-4 text-lg font-medium text-gray-900 dark:text-white">
                      <svg
                        class="flex-shrink-0 w-5 h-5 mr-2 text-gray-500 dark:text-gray-400"
                        fill="currentColor"
                        viewBox="0 0 20 20"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          fill-rule="evenodd"
                          d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-3a1 1 0 00-.867.5 1 1 0 11-1.731-1A3 3 0 0113 8a3.001 3.001 0 01-2 2.83V11a1 1 0 11-2 0v-1a1 1 0 011-1 1 1 0 100-2zm0 8a1 1 0 100-2 1 1 0 000 2z"
                          clip-rule="evenodd"
                        >
                        </path>
                      </svg>
                      <%= faq_entry[:question] %>
                    </h3>
                    <p class="text-gray-500 dark:text-gray-400">
                      <%= faq_entry[:answer] %>
                    </p>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </section>
      """
    else
      ~H"""
      <div></div>
      """
    end
  end

  defp enrich_with_faq_entries(assigns) do
    assigns =
      assigns
      |> Map.put_new(:faq_entries, [])
      |> add_warum_drei_wochen_osterferien()
      |> add_warum_nur_eine_woche_herbstferien()
      |> FederalStateFaq.add_wann_sind_in_location_year_vaction?()
      |> add_wann_beginnen_vacation_in_location_year()

    addon = rem(length(assigns.faq_entries), 2)
    half = length(assigns.faq_entries) |> div(2)

    {first_half, second_half} = Enum.split(assigns.faq_entries, half + addon)

    assigns
    |> Map.put(:first_half, first_half)
    |> Map.put(:second_half, second_half)
  end

  def add_warum_drei_wochen_osterferien(assigns) do
    days =
      Enum.filter(assigns.entries, fn entry -> entry.colloquial == "Osterferien" end)
      |> Enum.map(fn entry -> entry.days end)
      |> Enum.sum()

    new_entry =
      if days > 15 do
        [
          %{
            question: "Warum hat #{assigns.location.name} 3 Wochen Osterferien?",
            answer:
              "#{assigns.location.name} hat im Jahr #{assigns.year} nur eine Woche Herbstferien, weil die Sommerferien spät zu Ende gehen. Als Ausgleich dafür wurden die Osterferien verlängert."
          }
        ]
      else
        []
      end

    Map.put(assigns, :faq_entries, assigns.faq_entries ++ new_entry)
  end

  def add_warum_nur_eine_woche_herbstferien(assigns) do
    days =
      Enum.filter(assigns.entries, fn entry -> entry.colloquial == "Herbstferien" end)
      |> Enum.map(fn entry -> entry.days end)
      |> Enum.sum()

    new_entries =
      if days < 9 do
        [
          %{
            question: "Warum nur 1 Woche Herbstferien #{assigns.location.name}?",
            answer:
              "#{assigns.location.name} hat im Jahr #{assigns.year} nur eine Woche Herbstferien, weil die Sommerferien spät zu Ende gehen. Als Ausgleich dafür wurden die Osterferien verlängert."
          },
          %{
            question: "Warum Herbstferien kürzer?",
            answer:
              "#{assigns.location.name} hat im Jahr #{assigns.year} nur eine Woche Herbstferien, weil die Sommerferien spät zu Ende gehen. Als Ausgleich für dafür wurden die Osterferien verlängert."
          }
        ]
      else
        []
      end

    Map.put(assigns, :faq_entries, assigns.faq_entries ++ new_entries)
  end

  def add_wann_beginnen_vacation_in_location_year(assigns) do
    vacation_colloquial = hd(assigns.entries) |> Map.get(:colloquial)

    faq_entries = assigns.faq_entries

    preposition =
      case assigns.location.name do
        "Saarland" -> "im"
        _ -> "in"
      end

    first_hit =
      Enum.find(assigns.entries, fn entry -> entry.colloquial == vacation_colloquial end)

    bonus_answer =
      case Date.compare(first_hit.starts_on, assigns.requested_date) do
        :gt ->
          "Bis dahin sind es noch #{Date.diff(first_hit.starts_on, assigns.requested_date)} Tage."

        _ ->
          ""
      end

    faq_entries = [
      %{
        question:
          "Wann beginnen die #{vacation_colloquial} #{preposition} #{assigns.location.name}?",
        answer:
          "Die #{vacation_colloquial} #{preposition} #{assigns.location.name} beginnen am #{Calendar.strftime(first_hit.starts_on, "%d.%m.%Y")} (ein #{FeriendatenWeb.LocationYearFaqComponents.wochentag(first_hit.starts_on)}). #{bonus_answer}"
      }
      | faq_entries
    ]

    faq_entries = [
      %{
        question:
          "Wann sind #{assigns.year} #{vacation_colloquial} #{preposition} #{assigns.location.name}?",
        answer:
          "Die #{vacation_colloquial} #{preposition} #{assigns.location.name} beginnen am #{Calendar.strftime(first_hit.starts_on, "%d.%m.%Y")} (ein #{FeriendatenWeb.LocationYearFaqComponents.wochentag(first_hit.starts_on)}). #{bonus_answer}"
      }
      | faq_entries
    ]

    Map.put(assigns, :faq_entries, faq_entries)
  end
end

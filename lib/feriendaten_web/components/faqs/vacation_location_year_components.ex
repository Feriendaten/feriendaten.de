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

    render_faq(assigns)
  end

  defp render_faq(%{faq_entries: []} = assigns) do
    ~H"""
    <!-- No FAQ entries -->
    """
  end

  defp render_faq(assigns) do
    ~H"""
    <h2 class="pt-4 mb-8 text-2xl font-semibold tracking-tight text-gray-900 dark:text-white">
      FAQ
    </h2>

    <div class="grid grid-cols-1 gap-4 md:grid-cols-2" itemscope itemtype="https://schema.org/FAQPage">
      <%= for faq_entry <- @faq_entries do %>
        <div itemscope itemprop="mainEntity" itemtype="https://schema.org/Question">
          <h3 class="flex items-center mb-4 text-lg font-medium text-gray-900 dark:text-white">
            <div itemprop="name">
              <%= faq_entry[:question] %>
            </div>
          </h3>
          <div itemscope itemprop="acceptedAnswer" itemtype="https://schema.org/Answer">
            <p class="text-gray-500 dark:text-gray-400" itemprop="text">
              <%= faq_entry[:answer] %>
            </p>
          </div>
        </div>
      <% end %>
    </div>
    """
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

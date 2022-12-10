defmodule FeriendatenWeb.FederalStateFaq do
  def wann_sind_in_location_year_vaction?(location, year, entries) do
    vacation_colloquial = hd(entries) |> Map.get(:colloquial)
    joined_ferientermine = join_ferientermine(entries)

    question = "Wann sind in #{location.name} #{year} #{vacation_colloquial}?"

    answer =
      case length(String.split(joined_ferientermine, ",")) do
        1 ->
          "Am #{joined_ferientermine} sind #{vacation_colloquial} im Jahr #{year} in #{location.name}."

        _ ->
          "Die #{vacation_colloquial} im Jahr #{year} in #{vacation_colloquial} #{location.name} sind an den folgenden Terminen: " <>
            joined_ferientermine
      end

    %{question: question, answer: answer}
  end

  defp join_ferientermine(entries) do
    entries
    |> Enum.map(fn x ->
      "#{x.ferientermin}"
    end)
    |> Enum.join(", ")
    |> String.replace(" - ", "-")
  end
end

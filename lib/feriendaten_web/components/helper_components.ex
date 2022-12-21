defmodule FeriendatenWeb.HelperComponents do
  @moduledoc """
  Provides Helper components for the FeriendatenWeb application.
  """
  use FeriendatenWeb, :html

  attr :string, :string, required: true

  def hyphonate(assigns) do
    ~H"""
    <%= raw(enrich_with_hyphonates(@string)) %>
    """
  end

  def enrich_with_hyphonates(string) do
    string
    |> String.replace("Weihnachtsferien", "Weih&shy;nachts&shy;ferien")
    |> String.replace("Winterferien", "Winter&shy;ferien")
    |> String.replace("Frühjahrsferien", "Früh&shy;jahrs&shy;ferien")
    |> String.replace("Osterferien", "Oster&shy;ferien")
    |> String.replace(
      "Himmelfahrt- und Pfingstferien",
      "Him&shy;mel&shy;fahrt- und Pfingst&shy;ferien"
    )
    |> String.replace(
      "Himmelfahrtsferien",
      "Him&shy;mel&shy;fahrts&shy;ferien"
    )
    |> String.replace("Pfingstferien", "Pfingst&shy;ferien")
    |> String.replace("Sommerferien", "Sommer&shy;ferien")
    |> String.replace("Herbstferien", "Herbst&shy;ferien")
    |> String.replace("Baden-Württemberg", "Ba&shy;den-Würt&shy;tem&shy;berg")
    |> String.replace("Brandenburg", "Bran&shy;den&shy;burg")
    |> String.replace("Mecklenburg-Vorpommern", "Meck&shy;len&shy;burg-Vor&shy;pom&shy;mern")
    |> String.replace("Niedersachsen", "Nie&shy;der&shy;sach&shy;sen")
    |> String.replace("Schleswig-Holstein", "Schles&shy;wig-Hol&shy;stein")
    |> String.replace("Sachsen-Anhalt", "Sach&shy;sen-An&shy;halt")
    |> String.replace("Sachsen", "Sach&shy;sen")
    |> String.replace("Nordrhein-Westfalen", "Nord&shy;rhein-West&shy;fa&shy;len")
    |> String.replace("Rheinland-Pfalz", "Rhein&shy;land-Pfalz")
    |> String.replace("Bayern", "Bay&shy;ern")
    |> String.replace("Hessen", "Hes&shy;sen")
    |> String.replace("Berlin", "Berlin")
    |> String.replace("Bremen", "Bre&shy;men")
    |> String.replace("Hamburg", "Ham&shy;burg")
    |> String.replace("Saarland", "Saar&shy;land")
    |> String.replace("Thüringen", "Thü&shy;rin&shy;gen")
    |> String.replace("Weihnacht", "Weih&shy;nacht")
    |> String.replace("Mecklenburg", "Mecklen&shy;burg")
    |> String.replace("Vorpommern", "Vor&shy;pommern")
    |> String.replace("Nordrhein", "Nord&shy;rhein")
    |> String.replace("Westfalen", "West&shy;falen")
    |> String.replace("Rheinland", "Rhein&shy;land")
    |> String.replace("Schleswig", "Schles&shy;wig")
    |> String.replace("Ferien", "Fe&shy;ri&shy;en")
  end
end

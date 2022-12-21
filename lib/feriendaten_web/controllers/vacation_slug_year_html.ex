defmodule FeriendatenWeb.VacationSlugYearHTML do
  use FeriendatenWeb, :html

  import FeriendatenWeb.VacationsTableComponents
  import FeriendatenWeb.HelperComponents
  import FeriendatenWeb.VacationLocationYearComponents

  embed_templates "vacation_slug_year_html/*"
end

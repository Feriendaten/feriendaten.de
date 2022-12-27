defmodule FeriendatenWeb.VacationSlugHTML do
  use FeriendatenWeb, :html

  import FeriendatenWeb.FerienComponents
  import FeriendatenWeb.VacationLocationFaqComponents

  embed_templates "vacation_slug_html/*"
end

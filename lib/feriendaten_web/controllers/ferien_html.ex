defmodule FeriendatenWeb.FerienHTML do
  use FeriendatenWeb, :html

  import FeriendatenWeb.FerienComponents
  import FeriendatenWeb.LocationFaqComponents
  import FeriendatenWeb.LocationYearFaqComponents

  embed_templates "ferien_html/*"
end

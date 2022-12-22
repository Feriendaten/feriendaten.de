defmodule FeriendatenWeb.Layouts do
  use FeriendatenWeb, :html

  import FeriendatenWeb.FerienComponents
  import FeriendatenWeb.HeaderComponents
  import FeriendatenWeb.HelperComponents

  embed_templates "layouts/*"
end

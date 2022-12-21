defmodule FeriendatenWeb.Layouts do
  use FeriendatenWeb, :html

  import FeriendatenWeb.FerienComponents
  import FeriendatenWeb.HeaderComponents

  embed_templates "layouts/*"
end

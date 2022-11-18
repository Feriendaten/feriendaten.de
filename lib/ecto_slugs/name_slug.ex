defmodule Feriendaten.EctoSlug.NameSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end

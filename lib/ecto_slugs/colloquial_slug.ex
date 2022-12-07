defmodule Feriendaten.EctoSlug.ColloquialSlug do
  use EctoAutoslugField.Slug, from: :colloquial, to: :slug, always_change: true
end

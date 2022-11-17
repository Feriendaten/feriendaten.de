defmodule Feriendaten.LegacyRepo do
  use Ecto.Repo,
    otp_app: :feriendaten,
    adapter: Ecto.Adapters.Postgres
end

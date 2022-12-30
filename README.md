# Feriendaten

Anzeige von Schulferien, Feiertagen und anderen Terminen für Deutschland.

# Entwickler

Unsere Entwickler Dokumentation ist etwas rudimentär. Sorry dafür! Bitte eine E-Mail an sw@wintermeyer-consulting schreiben, falls Fragen aufkommen. Wir freuen uns über jeden neuen Entwickler, Bugreports und auch Pull Requests mit neuen Features oder Bugfixes.

## Datenbank

Wir gehen davon aus, das Sie ebenfalls PostgreSQL als Datenbank benutzen.

In diesem Repo finden Sie alle Daten der Jahre 2022 und 2023 (ohne Schulen). Sie können die Daten wir folgt einspielen:

```
$ mix ecto.create
$ psql feriendaten_dev < priv/repo/feriendaten_dev_seeds.dump
```

Schulen können Sie bei Bedarf von Hand anlegen.

## Start the server

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


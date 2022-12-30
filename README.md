# Feriendaten

Anzeige von Schulferien, Feiertagen und anderen Terminen für Deutschland.

# Entwickler

Unsere Entwickler Dokumentation ist etwas rudimentär. Sorry dafür! Bitte 
eine E-Mail an sw@wintermeyer-consulting schreiben, falls Fragen aufkommen.
Wir freuen uns über jeden neuen Entwickler, Bugreports und auch Pull 
Requests mit neuen Features oder Bugfixes.

## Phoenix

Grundkenntnisse in [Elixir](https://elixir-lang.org) sind für dieses Projekt klar von Vorteil. Das 
gleiche gilt für [Phoenix](https://www.phoenixframework.org). Eine minimale Einführung findet Ihr unter 
https://www.wintermeyer-consulting.de/books/phoenix/1.5/index.html

Wer [asdf](https://asdf-vm.com) benutzt, kann folgende Befehle benutzen:

```
$ git clone git@github.com:Feriendaten/feriendaten.de.git
$ cd feriendaten.de
$ asdf install
$ mix deps.get
```

## Datenbank

Wir gehen davon aus, das Sie ebenfalls 
[PostgreSQL](https://www.postgresql.org) als Datenbank in Ihrer 
Entwicklungsumgebung benutzen.

In diesem Repo finden Sie alle Daten der Jahre 2022 und 2023 (ohne 
Schulen). Sie können die Daten wir folgt einspielen:

```
$ mix ecto.create
$ psql feriendaten_dev < priv/repo/feriendaten_dev_seeds.dump
```

Schulen können Sie bei Bedarf von Hand anlegen.

## Server starten

```
$ iex -S mix phx.server
```

## Test Driven Development (TDD)

Sicherlich ist die Testabdeckung im Projekt nicht 100% perfekt. 
Aber sie sollte grobe Schnitzer gut erkennen können. 
`mix test` is your friend!
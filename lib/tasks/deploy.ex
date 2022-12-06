defmodule Mix.Tasks.Deploy do
  use Mix.Task

  @shortdoc "Run the deploy.sh script on the remote server"

  def run(_args) do
    # Bump the patch version number
    Mix.Task.run("bump_patch")

    _result = System.cmd("git", ["commit", "-m", "Bump patch version", "mix.exs"])
    _result = System.cmd("git", ["push", "origin", "main"])

    IO.puts("")
    IO.puts("Please ssh feriendaten@feriendaten.de and run the ~/bin/deploy.sh script")
  end
end

defmodule Mix.Tasks.Deploy do
  use Mix.Task

  @shortdoc "Run the deploy.sh script on the remote server"

  def run(_args) do
    # Bump the patch version number
    Mix.Task.run("bump_patch")

    _result = System.cmd("git", ["commit", "-m", "Bump patch version", "mix.exs"])
    _result = System.cmd("git", ["push", "origin", "main"])

    IO.puts("")
    IO.puts("Next steps:")
    IO.puts("")
    IO.puts("ssh feriendaten@feriendaten.de")
    IO.puts("")
    IO.puts("~/bin/deploy.sh")
    IO.puts("")
  end
end

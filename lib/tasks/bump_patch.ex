defmodule Mix.Tasks.BumpPatch do
  use Mix.Task

  @shortdoc "Bump the patch version number of the project's version number"

  @doc """
  This mix task allows you to bump the patch version number of the project's version number.

  To bump the patch version number, run:

      mix bump_patch
  """

  def run(_args) do
    # Read the project version number from the mix.exs file
    mix_file = File.read!("mix.exs")
    version_string_complete = Regex.run(~r/version: "(\d+\.\d+\.\d+)"/, mix_file, captures: [1])
    [_, version_string] = version_string_complete
    {:ok, version} = Version.parse(version_string)

    # Bump the patch version number
    new_patch = version.patch + 1
    new_version = %{version | patch: new_patch}

    # Update the project version number in the mix.exs file
    new_version_string = Version.to_string(new_version)

    new_mix_file =
      Regex.replace(
        ~r/version: "(\d+\.\d+\.\d+)"/,
        mix_file,
        "version: " <> "\"" <> new_version_string <> "\""
      )

    File.write!("mix.exs", new_mix_file)

    # Print the new project version number
    IO.puts("The project's version number has been bumped to #{new_version_string}.")
  end
end

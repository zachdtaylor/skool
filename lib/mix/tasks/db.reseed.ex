defmodule Mix.Tasks.Db.Reseed do
  use Mix.Task

  @shortdoc "Drops, creates, and seeds the database."

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("ecto.drop")
    Mix.Task.run("ecto.create")
    Mix.Task.run("ecto.migrate")
    Mix.Shell.cmd("mix run priv/repo/seeds.exs", fn output -> IO.write(output) end)
  end
end

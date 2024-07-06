defmodule Skool.Workers.Tasks do
  @moduledoc """
  The Tasks worker.
  """

  use Oban.Worker, queue: :default

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"type" => "create_tasks"} = args}) do
    user =
      args
      |> Map.get("user_id")
      |> Skool.Accounts.get_user!()

    args
    |> Map.get("course_id")
    |> Skool.Courses.get_course!()
    |> Skool.Tasks.create_tasks(user)
  end
end

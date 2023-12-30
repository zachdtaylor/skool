defmodule Skool.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Skool.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        completed_at: ~U[2023-12-29 05:49:00Z],
        description: "some description"
      })
      |> Skool.Tasks.create_task()

    task
  end
end

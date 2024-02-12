defmodule Skool.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Skool.Repo

  alias Skool.Accounts.User
  alias Skool.Courses.{Assignment, Course, Enrollment}
  alias Skool.Tasks.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks(%User{} = user) do
    user
    |> assignments_from_enrolled_courses()
  end

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  defp assignments_from_enrolled_courses(%User{} = user) do
    query =
      from a in Assignment,
        join: e in Enrollment,
        on: e.course_id == a.course_id,
        where: e.user_id == ^user.id

    Repo.all(query)
  end

  def create_tasks_for_course(%User{} = user, %Course{} = course) do
    create_tasks_for_checklist_assignments(user, course)
    create_tasks_for_task_assignments(user, course)
  end

  defp create_tasks_for_checklist_assignments(%User{} = user, %Course{} = course) do
    query = from(a in Assignment, where: a.course_id == ^course.id, where: a.kind == "checklist")

    query
    |> Repo.all()
    |> Enum.map(fn %Assignment{} = assignment ->
      create_task(%{
        assignment_id: assignment.id,
        user_id: user.id,
        due_date: assignment.due_date
      })
    end)
  end

  defp create_tasks_for_task_assignments(%User{} = user, %Course{} = course) do
    query = from(a in Assignment, where: a.course_id == ^course.id, where: a.kind == "task")

    query
    |> Repo.all()
    |> Enum.map(fn %Assignment{} = assignment ->
      create_task(%{
        assignment_id: assignment.id,
        user_id: user.id,
        due_date: assignment.due_date
      })
    end)
  end

  # defp create_tasks_for_recurring_assignments(%User{} = user, %Course{} = course) do
  #   query = from(a in Assignment, where: a.course_id == ^course.id, where: a.kind == "recurring")

  #   assignments = Repo.all(query)

  #   for date <- Date.range(course.start_date, course.end_date) do
  #     for assignment <- assignments do
  #     end
  #   end
  # end

  # defp requires_task_for_date?(%Assignment{kind: "recurring"} = assignment, date) do
  # end
end

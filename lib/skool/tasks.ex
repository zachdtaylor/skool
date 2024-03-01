defmodule Skool.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Skool.DateHelpers
  alias Skool.Repo
  alias Skool.Accounts.User
  alias Skool.Courses.{Assignment, ChecklistItem, Course, Enrollment}
  alias Skool.Tasks.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks(%User{} = user) do
    query =
      from a in Assignment,
        join: e in Enrollment,
        on: e.course_id == a.course_id,
        where: e.user_id == ^user.id

    Repo.all(query)
  end

  @doc """
  Returns the list of tasks for the provided user and date.

  If a date is not provided, defaults to today's date, based on the user's timezone.
  """
  def list_tasks_for_date(user, date \\ nil)

  def list_tasks_for_date(%User{} = user, nil),
    do: list_tasks_for_date(user, DateHelpers.today(user))

  def list_tasks_for_date(%User{} = user, %Date{} = date) do
    query =
      from t in Task,
        where: t.user_id == ^user.id,
        where: t.due_date == ^date

    query
    |> Repo.all()
    |> Repo.preload(assignment: [:course], checklist_item: [])
  end

  @doc """
  Returns the list of tasks for the provided user, due on the week of the given date.

  If a date is not provided, defaults to today's date, based on the user's timezone.
  """
  def list_tasks_for_week(user, date \\ nil)

  def list_tasks_for_week(%User{} = user, nil),
    do: list_tasks_for_week(user, DateHelpers.today(user))

  def list_tasks_for_week(%User{} = user, %Date{} = date) do
    day_of_week = Date.day_of_week(date, :sunday)
    start_date = Date.add(date, -day_of_week + 1)
    end_date = Date.add(start_date, 6)

    query =
      from t in Task,
        where: t.user_id == ^user.id,
        where: t.due_date >= ^start_date,
        where: t.due_date <= ^end_date

    query
    |> Repo.all()
    |> Repo.preload(assignment: [:course], checklist_item: [])
  end

  def complete_task(id) do
    task = Repo.get!(Task, id)

    task
    |> change_task(%{completed_at: DateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(%{field: value})
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}), do: Task.changeset(task, attrs)

  @doc """
  Creates all course tasks for the given user.

  ## Examples

      iex> create_tasks(%Course{}, %User{})
      {:ok, %{checklist: {1, nil}, checklist_item: {6, nil}, task: {1, nil}, recurring: {332, nil}}}

  """
  def create_tasks(%Course{} = course, %User{} = user) do
    inserted_at = DateTime.utc_now(:second)

    Multi.new()
    |> Multi.insert_all(:checklist, Task, build_tasks(:checklist, user, course, inserted_at))
    |> Multi.insert_all(
      :checklist_item,
      Task,
      build_tasks(:checklist_item, user, course, inserted_at)
    )
    |> Multi.insert_all(:task, Task, build_tasks(:task, user, course, inserted_at))
    |> Multi.insert_all(:recurring, Task, build_tasks(:recurring, user, course, inserted_at))
    |> Repo.transaction()
  end

  defp build_tasks(:checklist, %User{} = user, %Course{} = course, inserted_at) do
    query = from(a in Assignment, where: a.course_id == ^course.id, where: a.kind == ^"checklist")

    query
    |> Repo.all()
    |> Enum.map(fn %Assignment{} = assignment ->
      %{
        assignment_id: assignment.id,
        user_id: user.id,
        due_date: assignment.due_date,
        inserted_at: inserted_at
      }
    end)
  end

  defp build_tasks(:checklist_item, %User{} = user, %Course{} = course, inserted_at) do
    from(c in ChecklistItem,
      join: a in Assignment,
      on: c.assignment_id == a.id,
      where: a.course_id == ^course.id
    )
    |> Repo.all()
    |> Enum.map(fn %ChecklistItem{} = checklist_item ->
      %{
        assignment_id: checklist_item.assignment_id,
        checklist_item_id: checklist_item.id,
        user_id: user.id,
        due_date: checklist_item.due_date,
        inserted_at: inserted_at
      }
    end)
  end

  defp build_tasks(:task, %User{} = user, %Course{} = course, inserted_at) do
    from(a in Assignment, where: a.course_id == ^course.id, where: a.kind == ^"task")
    |> Repo.all()
    |> Enum.map(fn %Assignment{} = assignment ->
      %{
        assignment_id: assignment.id,
        user_id: user.id,
        due_date: assignment.due_date,
        inserted_at: inserted_at
      }
    end)
  end

  defp build_tasks(:recurring, %User{} = user, %Course{} = course, inserted_at) do
    query = from(a in Assignment, where: a.course_id == ^course.id, where: a.kind == ^"recurring")

    assignments = Repo.all(query)

    course.start_date
    |> Date.range(course.end_date)
    |> Enum.reduce([], fn date, acc ->
      acc ++ build_tasks_for_date(date, assignments, user, inserted_at)
    end)
  end

  defp build_tasks_for_date(date, assignments, user, inserted_at) do
    Enum.reduce(assignments, [], fn assignment, acc ->
      if in_assignment_date_range?(date, assignment) and
           requires_task_for_date?(assignment, date) do
        task_attrs = %{
          assignment_id: assignment.id,
          user_id: user.id,
          due_date: date,
          inserted_at: inserted_at
        }

        [task_attrs | acc]
      else
        acc
      end
    end)
  end

  defp requires_task_for_date?(%Assignment{repeats_every_unit: :day} = assignment, date) do
    date
    |> Date.diff(assignment.start_date)
    |> rem(assignment.repeats_every) == 0
  end

  defp requires_task_for_date?(%Assignment{repeats_every_unit: :week} = assignment, date) do
    repeats_on_week? =
      date
      |> Date.diff(assignment.start_date)
      |> rem(assignment.repeats_every * 7) <= 7

    if repeats_on_week? do
      repeats_on_day_of_week?(date, assignment)
    else
      false
    end
  end

  defp requires_task_for_date?(%Assignment{repeats_every_unit: :month} = assignment, date) do
    if Date.compare(date, assignment.start_date) == :eq do
      true
    else
      repeats_on_month? =
        (date.month - assignment.start_date.month)
        |> rem(assignment.repeats_every) == 0

      if repeats_on_month? do
        repeats_on_day_of_month?(date, assignment)
      else
        false
      end
    end
  end

  defp requires_task_for_date?(%Assignment{repeats_every_unit: :year} = assignment, date) do
    if Date.compare(date, assignment.start_date) == :eq do
      true
    else
      repeats_on_year? =
        (date.year - assignment.start_date.year)
        |> rem(assignment.repeats_every) == 0

      if repeats_on_year? do
        date.day == assignment.start_date.day and
          date.month == assignment.start_date.month
      else
        false
      end
    end
  end

  defp repeats_on_day_of_month?(date, %Assignment{repeats_on: "day"} = assignment),
    do: date.day == assignment.start_date.day

  defp repeats_on_day_of_month?(date, %Assignment{repeats_on: "first"} = assignment) do
    date.day <= 7 and Date.day_of_week(date) == Date.day_of_week(assignment.start_date)
  end

  defp repeats_on_day_of_month?(date, %Assignment{repeats_on: "second"} = assignment) do
    date.day > 7 and date.day <= 14 and
      Date.day_of_week(date) == Date.day_of_week(assignment.start_date)
  end

  defp repeats_on_day_of_month?(date, %Assignment{repeats_on: "third"} = assignment) do
    date.day > 14 and date.day <= 21 and
      Date.day_of_week(date) == Date.day_of_week(assignment.start_date)
  end

  defp repeats_on_day_of_month?(date, %Assignment{repeats_on: "fourth"} = assignment) do
    date.day > 21 and date.day <= 28 and
      Date.day_of_week(date) == Date.day_of_week(assignment.start_date)
  end

  defp repeats_on_day_of_month?(date, %Assignment{repeats_on: "last"} = assignment) do
    date.day + 7 > Date.days_in_month(date) and
      Date.day_of_week(date) == Date.day_of_week(assignment.start_date)
  end

  defp repeats_on_day_of_week?(date, %Assignment{} = assignment),
    do: String.contains?(assignment.repeats_on, day_of_week(date))

  defp day_of_week(date) do
    case Date.day_of_week(date) do
      1 -> "monday"
      2 -> "tuesday"
      3 -> "wednesday"
      4 -> "thursday"
      5 -> "friday"
      6 -> "saturday"
      7 -> "sunday"
    end
  end

  defp in_assignment_date_range?(date, %Assignment{} = assignment) do
    Date.diff(date, assignment.start_date) >= 0 and Date.diff(date, assignment.end_date) <= 0
  end
end

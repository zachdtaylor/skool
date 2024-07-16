defmodule Skool.Courses do
  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false
  alias Skool.Repo

  alias Skool.Courses.{Assignment, ChecklistItem, Course, CourseCollaborator, Enrollment}

  @doc """
  Returns the list of checklist items for an assignment.
  """
  def load_checklist_items(%Assignment{} = assignment) do
    from(ci in ChecklistItem,
      where: ci.assignment_id == ^assignment.id
    )
    |> Repo.all()
  end

  @doc """
  Preloads the assignments for a course.
  """
  def preload_assignments(%Course{} = course) do
    Repo.preload(course, :assignments)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking assignment changes.
  """
  def change_assignment(%Assignment{} = assignment, attrs \\ %{}) do
    Assignment.changeset(assignment, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking checklist item changes.
  """
  def change_checklist_item(%ChecklistItem{} = checklist_item, attrs \\ %{}) do
    ChecklistItem.changeset(checklist_item, attrs)
  end

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses(user) do
    Course
    |> from()
    |> join(:left, [c], cc in CourseCollaborator, on: cc.course_id == c.id)
    |> join(:left, [c], e in Enrollment, on: e.course_id == c.id and e.user_id == ^user.id)
    |> where([c, cc], cc.collaborator_id == ^user.id and is_nil(c.deleted_at))
    |> or_where([c, cc], c.created_by_id == ^user.id and is_nil(c.deleted_at))
    |> select([course, _course_collaborator, enrollment], %Course{
      id: course.id,
      name: course.name,
      start_date: course.start_date,
      end_date: course.end_date,
      status:
        fragment(
          "CASE
            WHEN ? IS NOT NULL THEN 'enrolled'
            WHEN ? IS NOT NULL THEN 'finalized'
            ELSE 'in_progress'
          END",
          enrollment.id,
          course.finalized_at
        ),
      finalized_at: course.finalized_at
    })
    |> Repo.all()
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Gets the user who created the given course.
  """
  def get_course_creator(course) do
    Repo.preload(course, :created_by).created_by
  end

  @doc """
  Gets a single assignment.

  Raises `Ecto.NoResultsError` if the Assignment does not exist.

  ## Examples

      iex> get_assignment!(123)
      %Assignment{}

      iex> get_assignment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_assignment!(id), do: Repo.get!(Assignment, id)

  @doc """
  Gets a single checklist item.

  Raises `Ecto.NoResultsError` if the ChecklistItem does not exist.

  ## Examples

      iex> get_checklist_item!(123)
      %ChecklistItem{}

      iex> get_checklist_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_checklist_item!(id), do: Repo.get!(ChecklistItem, id)

  @doc """
  Creates an assignment.

  ## Examples

      iex> create_assignment(%{field: value})
      {:ok, %Assignment{}}

      iex> create_assignment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_assignment(attrs \\ %{}) do
    %Assignment{}
    |> Assignment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a checklist item.

  ## Examples

      iex> create_checklist_item(%{field: value})
      {:ok, %ChecklistItem{}}

      iex> create_checklist_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_checklist_item(attrs \\ %{}) do
    %ChecklistItem{}
    |> ChecklistItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an assignment.

  ## Examples

      iex> update_assignment(assignment, %{field: new_value})
      {:ok, %Assignment{}}

      iex> update_assignment(assignment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_assignment(%Assignment{} = assignment, attrs) do
    assignment
    |> Assignment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a checklist item.

  ## Examples

      iex> update_checklist_item(checklist_item, %{field: new_value})
      {:ok, %ChecklistItem{}}

      iex> update_checklist_item(checklist_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_checklist_item(%ChecklistItem{} = checklist_item, attrs) do
    checklist_item
    |> ChecklistItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Deletes an assignment.

  ## Examples

      iex> delete_assignment(course)
      {:ok, %Course{}}

      iex> delete_assignment(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_assignment(%Assignment{} = assignment), do: Repo.delete(assignment)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  @doc """
  Adds a user as a collaborator on a course.
  """
  def invite_collaborator(course_id, collaborator_id) do
    %CourseCollaborator{}
    |> CourseCollaborator.changeset(%{course_id: course_id, collaborator_id: collaborator_id})
    |> Repo.insert()
  end

  @doc """
  Disinvite a user as a collaborator on a course.
  """
  def disinvite_collaborator(course_id, collaborator_id) do
    from(cc in CourseCollaborator,
      where: cc.course_id == ^course_id and cc.collaborator_id == ^collaborator_id
    )
    |> Repo.delete_all()
  end

  @doc """
  Enroll a user in a course.
  """
  def enroll_user(course_id, user_id) do
    enrollment = Enrollment.changeset(%Enrollment{}, %{course_id: course_id, user_id: user_id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:enrollment, enrollment)
    |> Oban.insert(:create_tasks_job, Skool.Workers.new_create_tasks(course_id, user_id))
    |> Repo.transaction()
  end

  @doc """
  Determines whether a user is enrolled in a course.
  """
  def is_enrolled?(course, user) do
    enrollment =
      from(e in Enrollment,
        where: e.course_id == ^course.id and e.user_id == ^user.id
      )
      |> Repo.one()

    !is_nil(enrollment)
  end

  @doc """
  Splits the weights of the course evenly among all assignments.
  """
  def split_weights!(%Course{} = course) do
    assignments = course.assignments
    weight_each = 1 / length(assignments)

    assignments
    |> Enum.map(&Assignment.changeset(&1, %{grade_weight: weight_each}))
    |> Enum.map(&Repo.update!(&1))

    course.id
    |> get_course!()
    |> preload_assignments()
  end
end

defmodule Skool.Courses.CourseCollaborator do
  use Ecto.Schema

  import Ecto.Changeset

  schema "courses_collaborators" do
    field :course_id, :id
    field :collaborator_id, :id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(course_collaborator, attrs) do
    course_collaborator
    |> cast(attrs, [:course_id, :collaborator_id])
    |> validate_required([:course_id, :collaborator_id])
  end
end

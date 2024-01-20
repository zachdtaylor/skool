defmodule Skool.Courses.Enrollment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "course_enrollments" do
    field :course_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  def changeset(course_enrollment, attrs) do
    course_enrollment
    |> cast(attrs, [:course_id, :user_id])
    |> validate_required([:course_id, :user_id])
  end
end

defmodule Skool.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  alias Skool.Accounts.User
  alias Skool.Courses.Assignment
  alias Skool.Courses.CourseCollaborator

  schema "courses" do
    field :name, :string
    field :description, :string
    field :category, :string
    field :start_date, :date
    field :end_date, :date
    field :deleted_at, :utc_datetime
    field :finalized_at, :utc_datetime

    has_many :assignments, Assignment

    belongs_to :created_by, User

    many_to_many :collaborators, User,
      join_through: CourseCollaborator,
      join_keys: [course_id: :id, collaborator_id: :id]

    field :status, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  def changeset(course, attrs) when not is_nil(course.finalized_at) do
    cast(course, attrs, [])
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [
      :name,
      :description,
      :category,
      :start_date,
      :end_date,
      :created_by_id,
      :finalized_at
    ])
    |> validate_required([:name, :start_date, :end_date, :created_by_id])
  end
end

defmodule Skool.Courses.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Skool.Courses.Course

  @kinds [:task, :checklist, :recurring]
  @base_attrs [:title, :description, :grade_weight, :kind, :course_id]

  schema "assignments" do
    field :title, :string
    field :description, :string
    field :kind, Ecto.Enum, values: @kinds, default: :task
    field :grade_weight, :float
    field :recurrance_interval, :float
    field :recurrance_unit, :string
    field :due_date, :date
    field :start_date, :date
    field :end_date, :date

    belongs_to :course, Course

    timestamps()
  end

  def kinds, do: Ecto.Enum.mappings(__MODULE__, :kind)

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> cast_and_validate_required(attrs)
    |> validate_number(:grade_weight, greater_than_or_equal_to: 0.0)
    |> validate_number(:grade_weight, less_than_or_equal_to: 1.0)
  end

  defp cast_and_validate_required(assignment, %{"kind" => "recurring"} = attrs) do
    assignment
    |> cast(attrs, @base_attrs ++ [:start_date, :end_date])
    |> validate_required((@base_attrs -- [:description]) ++ [:start_date, :end_date])
  end

  defp cast_and_validate_required(assignment, attrs) do
    assignment
    |> cast(attrs, @base_attrs ++ [:due_date])
    |> validate_required((@base_attrs -- [:description]) ++ [:due_date])
  end
end

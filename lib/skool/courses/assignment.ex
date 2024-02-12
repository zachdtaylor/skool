defmodule Skool.Courses.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Skool.Courses.Course
  alias Skool.Repo

  @kinds [:task, :checklist, :recurring]
  @base_attrs [:title, :grade_weight, :kind, :course_id]

  schema "assignments" do
    field :title, :string
    field :description, :string
    field :kind, Ecto.Enum, values: @kinds, default: :task
    field :grade_weight, :float
    field :due_date, :date
    field :start_date, :date
    field :end_date, :date
    field :repeats_every, :integer
    field :repeats_every_unit, Ecto.Enum, values: [:day, :week, :month, :year]
    field :repeats_on, :string

    belongs_to :course, Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(assignment, attrs) do
    assignment
    |> Repo.preload(:course)
    |> cast_and_validate_required(attrs)
    |> validate_number(:grade_weight, greater_than_or_equal_to: 0.0)
    |> validate_number(:grade_weight, less_than_or_equal_to: 1.0)
  end

  defp cast_and_validate_required(assignment, attrs)
       when not is_nil(assignment.course.finalized_at) do
    assignment
    |> cast(attrs, [])
  end

  defp cast_and_validate_required(assignment, %{"kind" => "recurring"} = attrs) do
    assignment
    |> cast(
      attrs,
      @base_attrs ++
        [:description, :start_date, :end_date, :repeats_every, :repeats_every_unit, :repeats_on]
    )
    |> validate_required(
      @base_attrs ++ [:start_date, :end_date, :repeats_every, :repeats_every_unit]
    )
    |> validate_number(:repeats_every, greater_than_or_equal_to: 1)
    |> validate_repeats_fields()
  end

  defp cast_and_validate_required(assignment, attrs) do
    assignment
    |> cast(attrs, @base_attrs ++ [:description, :due_date])
    |> validate_required(@base_attrs ++ [:due_date])
  end

  defp validate_repeats_fields(changeset) do
    case get_field(changeset, :repeats_every_unit) do
      nil ->
        changeset

      :day ->
        validate_change(changeset, :repeats_on, fn
          :repeats_on, nil ->
            []

          :repeats_on, _ ->
            [repeats_on: "Repeats on must be nil for assignments that repeat daily"]
        end)

      :week ->
        validate_change(changeset, :repeats_on, fn :repeats_on, repeats_on ->
          repeats_on
          |> String.split(".")
          |> Enum.all?(&valid_repeats_on_value?(&1, :week))
          |> case do
            true -> []
            false -> [repeats_on: "Invalid value for weekly repeats on"]
          end
        end)

      :month ->
        validate_change(changeset, :repeats_on, fn :repeats_on, repeats_on ->
          repeats_on
          |> String.split(".")
          |> Enum.all?(&valid_repeats_on_value?(&1, :month))
          |> case do
            true -> []
            false -> [repeats_on: "Invalid value for monthly repeats on"]
          end
        end)

      :year ->
        validate_change(changeset, :repeats_on, fn
          :repeats_on, nil ->
            []

          :repeats_on, _ ->
            [repeats_on: "Repeats on must be nil for assignments that repeat yearly"]
        end)
    end
  end

  defp valid_repeats_on_value?(repeats_on_value, :week) do
    case repeats_on_value do
      "monday" -> true
      "tuesday" -> true
      "wednesday" -> true
      "thursday" -> true
      "friday" -> true
      "saturday" -> true
      "sunday" -> true
      _ -> false
    end
  end

  defp valid_repeats_on_value?(repeats_on_value, :month) do
    case repeats_on_value do
      "day" -> true
      "first" -> true
      "second" -> true
      "third" -> true
      "fourth" -> true
      "last" -> true
      _ -> false
    end
  end
end

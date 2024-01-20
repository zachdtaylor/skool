defmodule Skool.Courses.ChecklistItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias Skool.Courses.Assignment

  schema "assignment_checklist_items" do
    field :title, :string
    field :description, :string
    field :grade_weight, :float
    field :due_date, :date

    belongs_to :assignment, Assignment

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(checklist_item, attrs) do
    checklist_item
    |> cast(attrs, [:title, :description, :grade_weight, :due_date, :assignment_id])
    |> validate_required([:title, :grade_weight, :due_date, :assignment_id])
    |> validate_number(:grade_weight, greater_than_or_equal_to: 0.0)
    |> validate_number(:grade_weight, less_than_or_equal_to: 1.0)
  end
end

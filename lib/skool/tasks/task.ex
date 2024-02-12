defmodule Skool.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Skool.Accounts.User
  alias Skool.Courses.{Assignment, ChecklistItem}

  schema "tasks" do
    field :completed_at, :utc_datetime
    field :due_date, :date
    field :grade, :float

    belongs_to :assignment, Assignment
    belongs_to :checklist_item, ChecklistItem
    belongs_to :grader, User
    belongs_to :user, User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :completed_at,
      :due_date,
      :grade,
      :assignment_id,
      :checklist_item_id,
      :grader_id,
      :user_id
    ])
    |> validate_required([:assignment_id, :user_id, :due_date])
  end
end

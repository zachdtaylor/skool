defmodule Skool.Repo.Migrations.CreateAssignments do
  use Ecto.Migration

  def change do
    create table(:assignments) do
      add :title, :string
      add :description, :string
      # checklist, task, recurring, etc.
      add :kind, :string
      add :grade_weight, :float
      add :course_id, references(:courses, on_delete: :delete_all)

      # fields depending on kind
      add :due_date, :date
      add :start_date, :date
      add :end_date, :date

      timestamps(type: :utc_datetime)
    end

    create table(:assignment_checklist_items) do
      add :assignment_id, references(:assignments, on_delete: :delete_all)
      add :title, :string
      add :description, :string
      add :grade_weight, :float
      add :due_date, :date

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create table(:assignment_checklist_item_completions) do
      add :assignment_checklist_item_id,
          references(:assignment_checklist_items, on_delete: :nothing)

      add :user_id, references(:users, on_delete: :delete_all)
      add :grader_id, references(:users, on_delete: :nilify_all)
      add :grade, :float
      add :completed_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create table(:assignment_completions) do
      add :assignment_id, references(:assignments, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)
      add :grader_id, references(:users, on_delete: :nilify_all)
      add :grade, :float
      add :completed_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end
  end
end

defmodule Skool.Repo.Migrations.ReworkTasksTable do
  use Ecto.Migration

  def change do
    drop table(:tasks)
    drop table(:assignment_completions)
    drop table(:assignment_checklist_item_completions)

    create table(:tasks) do
      add :assignment_id, references(:assignments, on_delete: :nothing)

      add :assignment_checklist_item_id,
          references(:assignment_checklist_items, on_delete: :nothing)

      add :user_id, references(:users, on_delete: :delete_all)
      add :grader_id, references(:users, on_delete: :nilify_all)
      add :grade, :float
      add :completed_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end
  end
end

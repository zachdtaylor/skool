defmodule Skool.Repo.Migrations.AddDueDateToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :due_date, :date
    end

    create unique_index(:tasks, [:assignment_id, :checklist_item_id, :user_id, :due_date])
  end
end

defmodule Skool.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :description, :string
      add :completed_at, :utc_datetime
      add :completed_by_id, references(:users, on_delete: :nothing)
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:completed_by_id])
    create index(:tasks, [:course_id])
  end
end

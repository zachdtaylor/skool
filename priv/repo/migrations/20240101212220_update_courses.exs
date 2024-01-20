defmodule Skool.Repo.Migrations.UpdateCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :start_date, :date
      add :end_date, :date
      add :category, :string
      add :deleted_at, :utc_datetime
    end

    create table(:courses_collaborators) do
      add :course_id, references(:courses, on_delete: :delete_all)
      add :collaborator_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime, updated_at: false)
    end
  end
end

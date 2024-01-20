defmodule Skool.Repo.Migrations.AddCourseEnrollments do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :finalized_at, :utc_datetime
    end

    create table(:course_enrollments) do
      add :course_id, references(:courses, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:course_enrollments, [:course_id, :user_id], unique: true)
  end
end

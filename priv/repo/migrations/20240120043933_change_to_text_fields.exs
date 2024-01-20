defmodule Skool.Repo.Migrations.ChangeToTextFields do
  use Ecto.Migration

  def change do
    alter table(:assignments) do
      modify :description, :text
    end

    alter table(:assignment_checklist_items) do
      modify :description, :text
    end

    alter table(:courses) do
      modify :description, :text
    end
  end
end
